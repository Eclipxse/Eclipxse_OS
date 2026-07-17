#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/themes/cursors/MARISHOKU/src"
OUTPUT="$ROOT/themes/cursors/MARISHOKU/cursors"

if ! command -v xcursorgen >/dev/null 2>&1; then
  printf '%s\n' 'xcursorgen is required to build the cursor theme.' >&2
  exit 1
fi

mkdir -p "$OUTPUT"
for config in "$SOURCE"/*.cursor; do
  name="$(basename "${config%.cursor}")"
  (cd "$SOURCE" && xcursorgen "$(basename "$config")" "$OUTPUT/$name")
done

ln -sfn left_ptr "$OUTPUT/default"
ln -sfn left_ptr "$OUTPUT/arrow"
ln -sfn hand2 "$OUTPUT/pointer"
ln -sfn xterm "$OUTPUT/text"
ln -sfn watch "$OUTPUT/wait"
printf 'Cursor theme ready: %s\n' "$OUTPUT"
