#!/bin/bash

echo ""
echo "markdown Count By Folder"
echo "==================================="


# List of doc plugin folders to scan
DOC_FOLDERS=("projects" "technical" "not-technical" "internal")

total=0

for base in "${DOC_FOLDERS[@]}"; do
  count=0
  while IFS= read -r file; do
    ((count++))
  done < <(find "$base" -type f \( -iname "*.md" -o -iname "*.mdx" \) | sort)
  echo "🧮 Count in $base: $count"
  ((total+=count))
done

echo ""
echo "==================================="
echo "🧾 Total Markdown files: $total"

