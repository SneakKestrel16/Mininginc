#!/usr/bin/env bash
# Export the Windows build and publish it as a GitHub release; the launcher installs the latest one.
# Usage: tools/release.sh <tag> [notes]     e.g. tools/release.sh v0.1.0 "First playable dig"
# GODOT overrides the editor path (default: the winget install pinned in project.yaml).
set -euo pipefail

tag=${1:?usage: tools/release.sh <tag> [notes]}
notes=${2:-}
GODOT=${GODOT:-C:/Users/Ockey/AppData/Local/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.2-stable_win64_console.exe}
cd "$(dirname "$0")/.."

[ -z "$(git status --porcelain)" ] || { echo "Commit or stash changes first: a release must match a commit." >&2; exit 1; }
git fetch -q origin main
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || { echo "Push main first: the release tag must point at a pushed commit." >&2; exit 1; }

rm -rf build/windows build/release
mkdir -p build/windows build/release
"$GODOT" --headless --path . --import > /dev/null 2>&1
# Export exits 0 on some failures, so check for the exe as well.
"$GODOT" --headless --path . --export-release "Windows Desktop" build/windows/Heartwake.exe
[ -f build/windows/Heartwake.exe ] || { echo "Export produced no Heartwake.exe." >&2; exit 1; }

powershell -NoProfile -Command "Compress-Archive -Path build/windows/* -DestinationPath build/release/Heartwake-windows.zip"
powershell -NoProfile -Command "Compress-Archive -Path tools/launcher/*, INSTALL.md -DestinationPath build/release/Heartwake-Launcher.zip"

gh release create "$tag" build/release/Heartwake-windows.zip build/release/Heartwake-Launcher.zip \
    --target main --title "Heartwake $tag" --notes "$notes"
