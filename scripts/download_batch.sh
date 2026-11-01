#!/usr/bin/env bash
# Download one batch of Figma export URLs right after download_assets returns them (URLs expire fast).
# usage: download_batch.sh <out_dir>   with stdin lines: <export.url><TAB><rel_path>
# Only Figma MCP export URLs are fetched, and only into <out_dir>.
set -uo pipefail
out="$(cd "$1" && pwd -P)" || { echo "no such dir: $1"; exit 1; }
url_re='^https://www\.figma\.com/api/mcp/asset/[A-Za-z0-9-]+\.(png|jpg)$'
fail=0
while IFS=$'\t' read -r url rel; do
  [ -z "${url:-}" ] && continue
  if ! [[ "$url" =~ $url_re ]]; then echo "REJECT url (not a Figma export URL): $rel"; fail=1; continue; fi
  if [[ "$rel" = /* || "/$rel/" == *"/../"* || "/$rel/" == *"/./"* || "$rel" != *.png ]]; then
    echo "REJECT path (must be a relative .png path inside out_dir): $rel"; fail=1; continue
  fi
  mkdir -p "$out/$(dirname "$rel")"
  if curl -f -sS -L --proto '=https' --max-redirs 3 --max-filesize 104857600 --retry 2 -o "$out/$rel" "$url"; then
    echo "ok   $rel"
  else
    echo "FAIL $rel"; rm -f "$out/$rel"; fail=1
  fi
done
exit $fail
