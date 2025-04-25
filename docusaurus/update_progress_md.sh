#!/bin/bash

echo ""
echo "markdown Count By Folder"
echo "==================================="

DOC_FOLDERS=("projects" "technical" "not-technical" "internal")
MARKDOWN_FILE="./internal/progress.md"  # Path to file with ## Progress section
TODAY=$(date +%F)
total=0

# Count files by folder
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

# Update the progress table
TMP_FILE=$(mktemp)

awk -v today="$TODAY" -v total="$total" '
  BEGIN { in_progress = 0; inserted = 0 }
  {
    print
    if ($0 ~ /^## Progress/) {
      in_progress = 1
    } else if (in_progress && $0 ~ /^\|[- ]+\|/) {
      # After header separator line, insert our new entry
      if (!inserted) {
        print "| " today " | " total "                      |"
        inserted = 1
        in_progress = 0
      }
    }
  }
' "$MARKDOWN_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$MARKDOWN_FILE"

echo "✅ Progress table updated in $MARKDOWN_FILE"
