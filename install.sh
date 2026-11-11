#!/bin/bash
# One-step setup on a new Mac: checks for Claude.app and builds the
# "Claude Mica" and "Claude Personal" launchers in ~/Applications.
# Usage: ./install.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d /Applications/Claude.app ]; then
  echo "First install Claude from https://claude.ai/download (drag it into /Applications), then run this again." >&2
  exit 1
fi

chmod +x "$HERE"/*.sh
mkdir -p "$HOME/Library/Application Support/ClaudeProfiles/personal"
"$HERE/make-apps.sh"

cat <<'MSG'

Done. Next steps:
  1. Quit Claude (Cmd+Q) if it is open.
  2. Open ~/Applications/Claude Personal and sign in with your PERSONAL account.
  3. Quit it, open ~/Applications/Claude Mica and sign in with your WORK (Mica) account.
  4. Drag "Claude Mica" and "Claude Personal" from ~/Applications to the Dock.
     Remove the plain Claude icon from the Dock, so you always open an account by name.
Sign in with only one instance running, so the sign-in returns to the right one.
MSG
