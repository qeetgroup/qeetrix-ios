#!/bin/sh
# The extended icons' size budget (docs/icons.md). Builds Tools/IconBudget in release — `NoExtendedIcons` names one core
# icon, `TwentyExtendedIcons` adds twenty from QeetrixIconsExtended — and fails unless:
#
# - the linker kept no extended icon's drawings in the first program and exactly the twenty in the second (each
#   icon's round outline is a string only its own declaration holds, so finding that whole string among the binary's
#   C strings says it shipped), and
# - the second program is no more than BUDGET_PER_ICON bytes per icon larger than the first.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
package="$root/Tools/IconBudget"
swift build -c release --package-path "$package" --product NoExtendedIcons
swift build -c release --package-path "$package" --product TwentyExtendedIcons
bin=$(swift build -c release --package-path "$package" --show-bin-path)
python3 -I - "$root" "$bin/NoExtendedIcons" "$bin/TwentyExtendedIcons" <<'PY'
import glob, os, re, sys

# Bytes each extended icon may add to a release binary: its encoded drawings (round and sharp outline, and the two
# filled drawings when upstream draws them) and its initialiser. Measured 2026-11-08; see docs/icons.md.
BUDGET_PER_ICON = 4096
TWENTY = ["alarm-clock", "anchor", "award", "backpack", "bike", "binoculars", "bird", "book-open", "brain", "bus",
          "cake", "car", "cat", "compass", "dog", "flame", "gift", "globe-lock", "heart", "sun"]

root, none_path, twenty_path = sys.argv[1:]
outline = {}
declaration = re.compile(r'QeetrixIconName\(\s*"([^"]+)", mirrors: (?:true|false),\s*roundOutline: "([^"]+)"')
for path in glob.glob(os.path.join(root, "Sources/QeetrixIconsExtended/Generated/QeetrixIconName+*.swift")):
    for name, drawing in declaration.findall(open(path).read()):
        outline[name] = drawing.encode()
if len(outline) < 1000 or not set(TWENTY) <= outline.keys():
    sys.exit(f"error: read {len(outline)} extended icons; Tools/IconBudget names the same twenty as this script")
# An icon whose drawing another icon shares — extended or core (clock-4 draws as clock) — can't be told apart by it;
# leave those out of the census.
core = open(os.path.join(root, "Sources/Qeetrix/Icons/Generated/QeetrixIconCatalog.swift")).read()
counts = {}
for drawing in list(outline.values()) + [d.encode() for _, d in declaration.findall(core)]:
    counts[drawing] = counts.get(drawing, 0) + 1
unique = {name: drawing for name, drawing in outline.items() if counts[drawing] == 1}

def kept(path):
    data = open(path, "rb").read()
    # Whole NUL-terminated strings, so a short drawing isn't found inside a longer one.
    strings = set(data.split(b"\0"))
    return {name for name, drawing in unique.items() if drawing in strings}, len(data)

none_kept, none_size = kept(none_path)
twenty_kept, twenty_size = kept(twenty_path)
problems = []
if none_kept:
    problems.append(f"the program without extended icons kept {len(none_kept)} of them: {sorted(none_kept)[:10]}")
expected = {name for name in TWENTY if name in unique}
if twenty_kept != expected:
    problems.append(f"the program with twenty kept {len(twenty_kept)}: extra {sorted(twenty_kept - expected)[:10]}, "
                    f"missing {sorted(expected - twenty_kept)}")
growth = twenty_size - none_size
budget = BUDGET_PER_ICON * len(TWENTY)
if growth > budget:
    problems.append(f"twenty extended icons add {growth} bytes, over the budget of {budget} ({BUDGET_PER_ICON} per icon)")
if problems:
    print("error: " + "\nerror: ".join(problems), file=sys.stderr)
    sys.exit(1)
print(f"✓ The linker keeps only the extended icons an app names: none without them, exactly twenty with them, "
      f"{growth} bytes for twenty ({growth // len(TWENTY)} per icon; budget {BUDGET_PER_ICON})")
PY
