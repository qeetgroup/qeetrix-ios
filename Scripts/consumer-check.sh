#!/bin/sh
# Installs Qeetrix the way an app installs a release, and tests the consumer app against it.
#
#   Scripts/consumer-check.sh [version] [work directory]
#
# Everything happens in a temporary directory; this repository, its history and its remote are never
# touched:
#   1. the working tree (tracked and untracked files, nothing ignored) is committed to a throwaway git
#      repository and tagged <version> (default 0.1.0-rc.1) there;
#   2. a copy of Examples/QeetrixConsumer is pointed at that repository by URL and exact version, instead
#      of the in-repository path;
#   3. Xcode resolves it — which must fetch Qeetrix alone, none of its test-only dependencies — then runs
#      the consumer's UI tests on the simulator and builds the app for devices in Release. The app target
#      treats warnings as errors in its own settings: a command-line override would also reach the
#      package, which Xcode builds with its warnings suppressed, as it does any remote package.
# A tag in a throwaway repository is not a published release; see Documentation/Releases/CONSUMER_INTEGRATION.md.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
version=${1:-0.1.0-rc.1}
work=${2:-$(mktemp -d "${TMPDIR:-/tmp}/qeetrix-consumer.XXXXXX")}
package="$work/qeetrix-ios"
consumer="$work/QeetrixConsumer"
step() { printf '\n▸ %s\n' "$1"; }

step "Package snapshot, tagged $version in $package"
rm -rf "$package" "$consumer"
mkdir -p "$package"
(cd "$root" && git ls-files -z --cached --others --exclude-standard) | (cd "$root" && rsync -a --from0 --files-from=- . "$package/")
git -C "$package" init -q
git -C "$package" add -A
git -C "$package" -c user.name="Qeetrix consumer check" -c user.email="consumer-check@localhost" commit -q -m "Qeetrix $version (consumer check)"
git -C "$package" tag "$version"
echo "commit $(git -C "$package" rev-parse --short HEAD), tag $(git -C "$package" tag)"

step "Consumer app, depending on file://$package at exactly $version"
cp -R "$root/Examples/QeetrixConsumer" "$consumer"
python3 - "$consumer/QeetrixConsumer.xcodeproj/project.pbxproj" "file://$package" "$version" <<'PY'
import sys
path, url, version = sys.argv[1:4]
s = open(path).read()
local = '''/* Begin XCLocalSwiftPackageReference section */
		5E0C1B000000000000000090 /* XCLocalSwiftPackageReference "../.." */ = {
			isa = XCLocalSwiftPackageReference;
			relativePath = ../..;
		};
/* End XCLocalSwiftPackageReference section */'''
remote = f'''/* Begin XCRemoteSwiftPackageReference section */
		5E0C1B000000000000000090 /* XCRemoteSwiftPackageReference "qeetrix-ios" */ = {{
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "{url}";
			requirement = {{
				kind = exactVersion;
				version = {version};
			}};
		}};
/* End XCRemoteSwiftPackageReference section */'''
assert local in s, "the consumer project no longer has the expected local package reference"
s = s.replace(local, remote)
s = s.replace('5E0C1B000000000000000090 /* XCLocalSwiftPackageReference "../.." */',
              '5E0C1B000000000000000090 /* XCRemoteSwiftPackageReference "qeetrix-ios" */')
product = '''			isa = XCSwiftPackageProductDependency;
			productName = Qeetrix;'''
assert product in s
s = s.replace(product, '''			isa = XCSwiftPackageProductDependency;
			package = 5E0C1B000000000000000090 /* XCRemoteSwiftPackageReference "qeetrix-ios" */;
			productName = Qeetrix;''')
open(path, "w").write(s)
PY

step "Resolve"
derived="$work/DerivedData"
xcodebuild -resolvePackageDependencies -project "$consumer/QeetrixConsumer.xcodeproj" -scheme QeetrixConsumer \
    -derivedDataPath "$derived" -clonedSourcePackagesDirPath "$work/SourcePackages" >"$work/resolve.log" 2>&1
resolved="$consumer/QeetrixConsumer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
cat "$resolved"
identities=$(grep '"identity"' "$resolved" | sed 's/.*: "\(.*\)".*/\1/' | tr '\n' ' ')
[ "$identities" = "qeetrix-ios " ] || { echo "✗ Resolved more than Qeetrix: $identities" >&2; exit 1; }
grep -q "\"version\" : \"$version\"" "$resolved" || { echo "✗ Not resolved at $version" >&2; exit 1; }
echo "✓ Resolved qeetrix-ios $version alone; no test-only dependency was fetched."

step "Consumer UI tests on the simulator"
sim=$("$root/Scripts/ci-simulator.sh")
xcodebuild test -project "$consumer/QeetrixConsumer.xcodeproj" -scheme QeetrixConsumer \
    -destination "platform=iOS Simulator,id=$sim" -derivedDataPath "$derived" \
    -clonedSourcePackagesDirPath "$work/SourcePackages" -collect-test-diagnostics never \
    >"$work/test.log" 2>&1 || { grep -E "error:|failed" "$work/test.log" >&2; exit 1; }
grep -E "Executed [0-9]+ test" "$work/test.log" | tail -1

step "Release build for devices"
xcodebuild build -project "$consumer/QeetrixConsumer.xcodeproj" -scheme QeetrixConsumer -configuration Release \
    -destination "generic/platform=iOS" -derivedDataPath "$derived" -clonedSourcePackagesDirPath "$work/SourcePackages" \
    CODE_SIGNING_ALLOWED=NO >"$work/release.log" 2>&1 || { grep -E "error:" "$work/release.log" >&2; exit 1; }
app=$(find "$derived/Build/Products/Release-iphoneos" -maxdepth 1 -name "QeetrixConsumer.app")
bundle=$(find "$app" -name "Qeetrix_Qeetrix.bundle" | head -n 1)
for resource in Fonts/CalSansVF.ttf Fonts/FiraCode-VF.ttf Fonts/CalSans-OFL.txt Fonts/FiraCode-OFL.txt \
    Licenses/qeetrix-icons-LICENSE.txt Metadata/token-provenance.json; do
    [ -f "$bundle/$resource" ] || { echo "✗ The app's Qeetrix bundle lacks $resource" >&2; exit 1; }
done
echo "✓ Release build for iOS devices; the app carries Qeetrix's fonts, licences and metadata ($(du -sh "$bundle" | cut -f1))."

printf '\n✓ Consumer check passed: %s, installed by version from %s.\n' "$version" "$package"
