#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 input.svg output.png [width]" >&2
  exit 1
fi

input=$1
output=$2
width=${3:-}

if [ ! -f "$input" ]; then
  echo "Input file not found: $input" >&2
  exit 1
fi

mkdir -p "$(dirname "$output")"

if command -v qlmanage >/dev/null 2>&1; then
  tmpdir=$(mktemp -d)
  size_arg=1024
  if [ -n "$width" ]; then
    size_arg=$width
  fi
  qlmanage -t -s "$size_arg" -o "$tmpdir" "$input" >/dev/null 2>&1
  thumbnail="$tmpdir/$(basename "$input").png"
  if [ -f "$thumbnail" ]; then
    mv "$thumbnail" "$output"
    rmdir "$tmpdir" 2>/dev/null || true
    exit 0
  fi
  rmdir "$tmpdir" 2>/dev/null || true
fi

if command -v rsvg-convert >/dev/null 2>&1; then
  if [ -n "$width" ]; then
    rsvg-convert -w "$width" "$input" -o "$output"
  else
    rsvg-convert "$input" -o "$output"
  fi
  exit 0
fi

if command -v inkscape >/dev/null 2>&1; then
  if [ -n "$width" ]; then
    inkscape "$input" --export-type=png --export-width="$width" --export-filename="$output" >/dev/null 2>&1
  else
    inkscape "$input" --export-type=png --export-filename="$output" >/dev/null 2>&1
  fi
  exit 0
fi

if command -v magick >/dev/null 2>&1; then
  if [ -n "$width" ]; then
    magick -background none "$input" -resize "${width}x" "$output"
  else
    magick -background none "$input" "$output"
  fi
  exit 0
fi

echo "No supported converter found. Install rsvg-convert or Inkscape, or use macOS qlmanage." >&2
exit 1
