#!/bin/sh
# Scaffold a component from Templates/Component, at the paths in Documentation/Standards/COMPONENT_CONTRACT.md.
#
#   Scripts/new-component.sh <Family> <Component> --category "<docs category>" [--slug <web slug>] [--dry-run]
#
#   Scripts/new-component.sh Checkbox Checkbox --category "Forms & inputs"
#   Scripts/new-component.sh Input TextArea --category "Forms & inputs" --slug textarea --dry-run
#
# <Family> is the qeetrix-ui family the web component belongs to (component-manifest.json "category");
# --slug defaults to the component name in kebab case. It never overwrites: an existing component stops
# the run with the reasons and changes nothing.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen new-component "$@" --root "$root"
