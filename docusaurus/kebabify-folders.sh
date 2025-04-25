#!/bin/bash

# List of doc plugin folders to scan
DOC_FOLDERS=("projects" "technical" "not-technical" "internal")

# Default to preview mode
RENAME=false

# Check for --rename flag
if [[ "$1" == "--rename" ]]; then
  RENAME=true
  echo "🛠 Rename mode: ENABLED"
else
  echo "👀 Preview mode: Showing what would be renamed"
  echo "👉 To actually rename, run: $0 --rename"
fi

# Helper to kebab-case a string
kebabify() {
  echo "$1" | \
    tr '[:upper:]' '[:lower:]' | \
    sed -E 's/[^a-z0-9]+/-/g' | \
    sed -E 's/^-+|-+$//g'
}

# Process folders
for base in "${DOC_FOLDERS[@]}"; do
  echo ""
  echo "📂 Scanning: $base"

  find "$base" -depth -type d | while read dir; do
    parent=$(dirname "$dir")
    current=$(basename "$dir")
    kebab=$(kebabify "$current")

    if [[ "$current" != "$kebab" ]]; then
      newpath="$parent/$kebab"
      echo "→ $dir → $newpath"
      if [ "$RENAME" = true ]; then
        mv "$dir" "$newpath"
      fi
    fi
  done
done
