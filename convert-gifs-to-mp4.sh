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
  # -i "$gif": read the source GIF.
  # -movflags +faststart: put the MP4 index near the start for quicker network playback startup.
  # -vf scale=...: convert RGB to YCbCr with the BT.709 matrix and TV-range levels.
  # -colorspace bt709: label the output matrix coefficients as BT.709.
  # -color_range tv: label the output samples as limited (TV) range.
  # -x264-params: signal BT.709 primaries/matrix, sRGB transfer, and limited range in H.264.
  #   These are H.264 color-description tags; transfer=... labels the samples, it does not transform them.
  # "$output": write the MP4 to this path.
  ffmpeg -i "$gif" \
    -movflags +faststart \
    -vf 'scale=out_color_matrix=bt709:out_range=tv' \
    -colorspace bt709 \
    -color_range tv \
    -x264-params 'colorprim=bt709:transfer=iec61966-2-1:colormatrix=bt709:fullrange=off' \
    "$output"
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
