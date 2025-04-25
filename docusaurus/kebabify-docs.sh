#!/bin/bash

# List of folders to scan
DOC_FOLDERS=("projects" "technical" "not-technical" "internal")

# Converts all .md and .mdx files to kebab-case in those folders

for folder in "${DOC_FOLDERS[@]}"; do
  echo "Scanning: $folder"
  find "$folder" -type f \( -name "*.md" -o -name "*.mdx" \) | while read filepath; do
    dir=$(dirname "$filepath")
    file=$(basename "$filepath")
    ext="${file##*.}"
    name="${file%.*}"

    kebab=$(echo "$name" | \
      tr '[:upper:]' '[:lower:]' | \
      sed -E 's/[^a-z0-9]+/-/g' | \
      sed -E 's/^-+|-+$//g')

    newname="${kebab}.${ext}"

    if [[ "$file" != "$newname" ]]; then
      echo "Renaming: $file → $newname"
      mv "$filepath" "$dir/$newname"
    fi
  done
done
