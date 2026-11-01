#!/usr/bin/env bash
# Upload one exported page folder to OpenViking and verify it landed.
# usage: upload.sh <local_page_dir> <target_parent_uri> [--replace]
#   target_parent_uri: the folder the user chose, e.g. viking://resources/ui-design-reference
#   --replace: remove the existing remote page folder first. Only when the user asked to replace it.
set -euo pipefail
src="${1%/}"; parent="${2%/}"; mode="${3:-}"
[ -d "$src" ] || { echo "not a folder: $src"; exit 1; }
[[ "$parent" =~ ^viking://(resources|user/[^/]+/resources)(/[^/]+)+$ ]] || {
  echo "refusing target parent '$parent': must be a named folder under viking://resources/ or viking://user/<you>/resources/"; exit 1; }
[[ "$parent" == *"/memories"* || "$parent" == *"/skills"* ]] && { echo "refusing: designs never go under memories or skills"; exit 1; }
name="$(basename "$src")"; target="$parent/$name"
if ov stat "$target" >/dev/null 2>&1; then
  if [ "$mode" = "--replace" ]; then
    echo "Replacing $target. Current contents:"; ov tree "$target" 2>&1 | head -40
    ov rm "$target" --recursive --wait
  else
    echo "exists: $target — ask the user: re-run with --replace, or upload changed files one by one with --to"; exit 2
  fi
fi
ov mkdir "$parent" >/dev/null 2>&1 || true
ov add-resource "$src" --to "$target" --wait --timeout 1800
# Verify: every local PNG must exist remotely (older OV versions store media as <file>.png/<file>.png).
missing=0
while IFS= read -r f; do
  rel="${f#$src/}"
  ov stat "$target/$rel" >/dev/null 2>&1 || ov stat "$target/$rel/$(basename "$rel")" >/dev/null 2>&1 \
    || { echo "missing remote: $rel"; missing=$((missing+1)); }
done < <(find "$src" -type f -name '*.png')
echo "local $(find "$src" -type f -name '*.png' | wc -l | tr -d ' ') png, missing remote $missing"
[ "$missing" -eq 0 ]
