#!/bin/bash

# Generate Daily Leadership Briefing at 5am
# Timestamp the file and keep a rolling 30-day history

cd /Users/yves-erikslater/Desktop/PKA || exit 1

# Generate today's date
TODAY=$(date +%Y-%m-%d)
BRIEFING_FILE="daily-briefing.html"
ARCHIVE_DIR="briefing-history"

# Create archive directory if needed
mkdir -p "$ARCHIVE_DIR"

# Keep the main briefing current
cp "$BRIEFING_FILE" "$ARCHIVE_DIR/briefing-$TODAY.html"

# Clean up files older than 30 days
find "$ARCHIVE_DIR" -name "briefing-*.html" -mtime +30 -delete

echo "Daily briefing generated and archived: $TODAY"
