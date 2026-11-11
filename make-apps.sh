#!/bin/bash
# Builds two Dock launchers in ~/Applications:
#   Claude Mica.app      opens the work account (Claude's normal data folder)
#   Claude Personal.app  opens the personal account (its own data folder)
# Each starts the official /Applications/Claude.app (never copied or re-signed),
# or brings that account to the front if it is already open.
# Run once per Mac; no need to re-run after Claude updates.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

build() { # app-name profile icon
  local out="$HOME/Applications/$1.app" profile="$2" icon="$3"
  rm -rf "$out"
  osacompile -o "$out" -e "do shell script \"PROFILE=$profile /bin/bash \" & quoted form of (POSIX path of (path to me) & \"Contents/Resources/launch.sh\")"
  cp "$HERE/claude-launch.sh" "$out/Contents/Resources/launch.sh"
  chmod +x "$out/Contents/Resources/launch.sh"
  if [ -f "$icon" ]; then
    cp "$icon" "$out/Contents/Resources/applet.icns"
    rm -f "$out/Contents/Resources/Assets.car"
  fi
  xattr -cr "$out"
  codesign --force --deep --sign - "$out" >/dev/null 2>&1
  touch "$out"
  echo "built $out"
}

mkdir -p "$HOME/Applications"
build "Claude Mica"     default  "/Applications/Claude.app/Contents/Resources/electron.icns"  # official icon
build "Claude Personal" personal "$HERE/assets/claude-personal.icns"                        # white, orange star
