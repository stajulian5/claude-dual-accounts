#!/bin/bash
# Opens one Claude account. Both accounts run the official, Anthropic-signed
# /Applications/Claude.app; each has its own data folder, so both can be signed
# in and linked to this Mac at the same time.
#   PROFILE=default  Claude's normal data folder (work / Mica)
#   PROFILE=personal ~/Library/Application Support/ClaudeProfiles/personal
# If that account is already running, it is brought to the front instead.
set -euo pipefail
APP="/Applications/Claude.app"
BIN="$APP/Contents/MacOS/Claude"
PROFILE="${PROFILE:-personal}"

if [ ! -d "$APP" ]; then
  echo "Claude.app is not in /Applications. Install it from https://claude.ai/download first." >&2
  exit 1
fi

if [ "$PROFILE" = "default" ]; then
  DATA=""
else
  DATA="$HOME/Library/Application Support/ClaudeProfiles/$PROFILE"
  mkdir -p "$DATA"
fi

# PID of the main Claude process for this profile (helpers are not matched)
pid="$(ps -axo pid=,args= | awk -v bin="$BIN" -v data="$DATA" '
  { p = $1; $1 = ""; sub(/^ /, "") }
  index($0, bin) == 1 && (length($0) == length(bin) || substr($0, length(bin) + 1, 1) == " ") {
    has = index($0, "--user-data-dir=") > 0
    if (data == "" && !has) { print p; exit }
    if (data != "" && index($0, "--user-data-dir=" data) > 0) { print p; exit }
  }')"

if [ -n "$pid" ]; then
  osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $pid) to true" >/dev/null 2>&1 || true
  exit 0
fi

if [ -z "$DATA" ]; then
  open -n -a "$APP"
else
  open -n -a "$APP" --args --user-data-dir="$DATA"
fi
