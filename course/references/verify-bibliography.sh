#!/usr/bin/env bash
# VoIPSec — verify the bibliography's web references are reachable.
# Extracts every URL from bibliography.md and checks each returns 2xx/3xx.
#
# Needs outbound network. Under the cron build loop the sandbox may block egress, so run this
# manually (or in CI) where the network is available. `list` mode needs no network.
#
# Usage:
#   verify-bibliography.sh list      # print the extracted URLs (offline, fast)
#   verify-bibliography.sh           # check reachability (needs network); exit 1 if any broken
set -u
BIB="$(cd "$(dirname "$0")" && pwd)/bibliography.md"
[ -f "$BIB" ] || { echo "bibliography.md not found next to this script"; exit 3; }

# Exclude spaces, markdown/code punctuation, and the rfcNNNN template placeholder.
urls() {
  grep -oE 'https?://[^ )>|`]+' "$BIB" \
    | sed 's/[.,`]*$//' \
    | grep -v 'rfcNNNN' \
    | sort -u
}

if [ "${1:-}" = "list" ]; then
  urls; echo "---"; echo "$(urls | wc -l) unique URLs"; exit 0
fi

command -v curl >/dev/null 2>&1 || { echo "needs curl"; exit 3; }

total=0; ok=0; bad=0; badlist=""
while IFS= read -r url; do
  [ -n "$url" ] || continue
  total=$((total+1))
  code=$(curl -sS -o /dev/null -m 12 -L -A "voipsec-bib-check" -w '%{http_code}' -I "$url" 2>/dev/null || echo 000)
  case "$code" in 2*|3*) : ;; *)   # some hosts reject HEAD; retry with GET
    code=$(curl -sS -o /dev/null -m 12 -L -A "voipsec-bib-check" -w '%{http_code}' "$url" 2>/dev/null || echo 000) ;;
  esac
  case "$code" in
    2*|3*) ok=$((ok+1)) ;;
    *)     bad=$((bad+1)); badlist="$badlist
  $code  $url" ;;
  esac
  printf '%s  %s\n' "$code" "$url"
done <<EOF
$(urls)
EOF

echo "----"
echo "bibliography links: $ok/$total reachable, $bad unreachable"
[ "$bad" -eq 0 ] && exit 0 || { printf 'unreachable:%s\n' "$badlist"; exit 1; }
