#!/bin/sh
# Scaffold a component from Templates/Component, at the paths in Documentation/Standards/COMPONENT_CONTRACT.md.
#
#   Scripts/new-component.sh <Family> <Component> --category "<docs category>" [--slug <web slug>] [--dry-run]
#
#   Scripts/new-component.sh Checkbox Checkbox --category "Forms & inputs"
#   Scripts/new-component.sh Input TextArea --category "Forms & inputs" --slug textarea --dry-run
#
# <Family> is the @qeetrix/react family the web component belongs to, in UpperCamelCase (the "name" in
# Upstream/qeetrix-react/component-manifest.json, e.g. number-field → NumberField); --slug names the
# web part when it differs from the component name, and the ui.qeet.in page is its kebab case. It never overwrites: an existing component stops
# the run with the reasons and changes nothing.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen new-component "$@" --root "$root"
