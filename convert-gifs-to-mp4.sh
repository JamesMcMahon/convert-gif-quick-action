#!/usr/bin/env bash

# Convert one GIF, or every GIF in a directory tree, to MP4.
# Originals are kept. Existing MP4s are never overwritten; numbered names are used.

set -u

usage() {
  echo "Usage: $0 [--trash-originals] <gif-file-or-directory> [...]" >&2
  exit 2
}

convert_gif() {
  local gif=$1
  local name=${gif%.*}
  local frame_count

  if ! frame_count=$(ffprobe -v error -select_streams v:0 -count_frames \
    -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 "$gif"); then
    echo "Error: could not probe GIF: $gif" >&2
    return 1
  fi
  if [[ "$frame_count" =~ ^[0-9]+$ ]] && [ "$frame_count" -le 1 ]; then
    echo "Skipping static GIF: $gif"
    return 0
  fi
  local output="$name.mp4"
  local number=1

  while [ -e "$output" ]; do
    output="${name}_${number}.mp4"
    number=$((number + 1))
  done

  echo "Converting: $gif -> $output"
  # FFmpeg's defaults balance quality, size, speed, and playback support, so where
  # possible we are using defaults.
  # -nostdin: avoid some very strange behavior that happens when running this in a loop.
  # -i "$gif": read the source GIF.
  # -movflags +faststart: put the MP4 index near the start for quicker network playback startup.
  # -vf scale=...: convert RGB to YCbCr with the BT.709 matrix and TV-range levels.
  # -colorspace bt709: label the output matrix coefficients as BT.709.
  # -color_range tv: label the output samples as limited (TV) range.
  # -x264-params: signal BT.709 primaries/matrix, sRGB transfer, and limited range in H.264.
  #   These are H.264 color-description tags; transfer=... labels the samples, it does not transform them.
  # "$output": write the MP4 to this path.
  if ffmpeg -nostdin -i "$gif" \
    -movflags +faststart \
    -vf 'scale=out_color_matrix=bt709:out_range=tv' \
    -colorspace bt709 \
    -color_range tv \
    -x264-params 'colorprim=bt709:transfer=iec61966-2-1:colormatrix=bt709:fullrange=off' \
    "$output"; then
    if [ ! -f "$output" ]; then
      echo "Error: conversion produced no output: $output" >&2
      return 1
    fi
    if [ "$trash_originals" = true ]; then
      if ! "${TRASH_COMMAND:-/usr/bin/trash}" "$gif"; then
        echo "Error: could not move original to Trash: $gif" >&2
        return 1
      fi
    fi
    return 0
  else
    local status=$?
    rm -f -- "$output"
    return "$status"
  fi
}

trash_originals=false
if [ "$#" -gt 0 ] && [ "$1" = "--trash-originals" ]; then
  trash_originals=true
  shift
fi
[ "$#" -gt 0 ] || usage

status=0
for input in "$@"; do
  if [ -f "$input" ]; then
    convert_gif "$input" || status=1
  elif [ -d "$input" ]; then
    while IFS= read -r -d '' gif; do
      convert_gif "$gif" || status=1
    done < <(find "$input" -type f -iname '*.gif' -print0)
  else
    echo "Error: not a file or directory: $input" >&2
    status=1
  fi
done
exit "$status"
