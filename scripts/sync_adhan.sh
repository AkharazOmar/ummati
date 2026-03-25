#!/bin/bash
# Scans assets/sounds/adhan/ and:
# 1. Generates assets/data/adhan_list.json
# 2. Copies files to android/app/src/main/res/raw/ (prefixed with adhan_)

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

ADHAN_DIR="$PROJECT_DIR/assets/sounds/adhan"
RAW_DIR="$PROJECT_DIR/android/app/src/main/res/raw"
JSON_FILE="$PROJECT_DIR/assets/data/adhan_list.json"

mkdir -p "$RAW_DIR"

# Clean old adhan files from raw
find "$RAW_DIR" -name 'adhan_*' -delete

# Build JSON array and copy files
echo '[' > "$JSON_FILE"
first=true

for file in "$ADHAN_DIR"/*.mp3 "$ADHAN_DIR"/*.wav "$ADHAN_DIR"/*.ogg "$ADHAN_DIR"/*.m4a; do
  [ -f "$file" ] || continue

  filename="$(basename "$file")"
  name="${filename%.*}"
  ext="${filename##*.}"

  # Android raw resource name: lowercase, no hyphens
  # If name already starts with "adhan", don't add the prefix again
  clean_name="$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr '-' '_')"
  if echo "$clean_name" | grep -q "^adhan"; then
    raw_name="$clean_name"
  else
    raw_name="adhan_${clean_name}"
  fi

  # Copy to Android raw
  cp "$file" "$RAW_DIR/${raw_name}.${ext}"

  # Append to JSON
  if [ "$first" = true ]; then
    first=false
  else
    echo ',' >> "$JSON_FILE"
  fi

  printf '  {"id": "%s", "name": "%s", "file": "%s", "androidRaw": "%s"}' \
    "$raw_name" "$name" "$filename" "$raw_name" >> "$JSON_FILE"
done

echo '' >> "$JSON_FILE"
echo ']' >> "$JSON_FILE"

echo "Generated $JSON_FILE with $(grep -c '"id"' "$JSON_FILE") adhan(s)"
echo "Synced to $RAW_DIR:"
ls "$RAW_DIR"/adhan_*
