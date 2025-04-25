#!/bin/bash

# List of doc plugin folders to scan
DOC_FOLDERS=("projects" "technical" "not-technical" "internal")

echo "📄 Listing all .md and .mdx files:"
echo "-----------------------------------"

total=0

for base in "${DOC_FOLDERS[@]}"; do
  echo ""
  echo "📁 Folder: $base"

  count=0
  while IFS= read -r file; do
    echo " - $file"
    ((count++))
  done < <(find "$base" -type f \( -iname "*.md" -o -iname "*.mdx" \) | sort)

  echo "🧮 Count in $base: $count"
  ((total+=count))
done

echo ""
echo "==================================="
echo "🧾 Total Markdown files: $total"
