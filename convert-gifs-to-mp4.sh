#!/usr/bin/env bash

# Convert one GIF, or every GIF in a directory tree, to MP4.
# Originals are kept. Existing MP4s are never overwritten; numbered names are used.

set -u

usage() {
  echo "Usage: $0 <gif-file-or-directory>" >&2
  exit 2
}

convert_gif() {
  local gif=$1
  local name=${gif%.*}
  local output="$name.mp4"
  local number=1

  while [ -e "$output" ]; do
    output="${name}_${number}.mp4"
    number=$((number + 1))
  done

  echo "Converting: $gif -> $output"
  ffmpeg -i "$gif" "$output"
}

[ "$#" -eq 1 ] || usage
input=$1

if [ -f "$input" ]; then
  convert_gif "$input"
elif [ -d "$input" ]; then
  while IFS= read -r -d '' gif; do
    convert_gif "$gif" || exit $?
  done < <(find "$input" -type f -iname '*.gif' -print0)
else
  echo "Error: not a file or directory: $input" >&2
  exit 1
fi
