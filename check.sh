#!/usr/bin/env bash
# Uptime check for clicloud, run by .github/workflows/uptime.yml every 5 minutes.
# Each target line: name|url|expected HTTP status|text the body must contain (optional).
# A target counts as down only after 3 failed tries 20 seconds apart, so a single blip doesn't alert.
# Prints one line per target; writes the down ones to $DOWN_FILE (default down.txt); exits 1 if any are down.
set -uo pipefail

TARGETS_FILE="${TARGETS_FILE:-$(dirname "$0")/targets.txt}"
DOWN_FILE="${DOWN_FILE:-down.txt}"
TRIES="${TRIES:-3}"
WAIT="${WAIT:-20}"
: > "$DOWN_FILE"

check() { # url status needle -> 0 if fine; prints why not
  local url="$1" want="$2" needle="$3" body code
  body="$(mktemp)"
  local err; err="$(mktemp)"
  code="$(curl -sS -L -o "$body" -w '%{http_code}' --max-time 15 -A "clicloud-uptime" "$url" 2>"$err")" || { echo "no answer: $(head -c 120 "$err" | tr '\n' ' ')"; rm -f "$body" "$err"; return 1; }
  rm -f "$err"
  if [ "$code" != "$want" ]; then echo "HTTP $code, expected $want"; rm -f "$body"; return 1; fi
  if [ -n "$needle" ] && ! grep -qF -- "$needle" "$body"; then echo "answered $code but without \"$needle\""; rm -f "$body"; return 1; fi
  rm -f "$body"; return 0
}

down=0
while IFS='|' read -r name url want needle || [ -n "${name:-}" ]; do
  case "$name" in ''|'#'*) continue ;; esac
  why=""
  for i in $(seq 1 "$TRIES"); do
    if why="$(check "$url" "$want" "$needle")"; then why=""; break; fi
    [ "$i" -lt "$TRIES" ] && sleep "$WAIT"
  done
  if [ -z "$why" ]; then
    echo "up    $name  $url"
  else
    echo "DOWN  $name  $url  ($why)"
    echo "- **$name** ($url): $why" >> "$DOWN_FILE"
    down=1
  fi
done < "$TARGETS_FILE"
exit "$down"
