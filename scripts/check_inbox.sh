#!/bin/bash

INBOX="/Users/yves-erikslater/Desktop/PKA/Owner Inbox"
TEAM_INBOX="/Users/yves-erikslater/Desktop/PKA/Team Inbox"
PROCESSED_LOG="/Users/yves-erikslater/Desktop/PKA/.processed_files.txt"
WORK_DIR="/Users/yves-erikslater/Desktop/PKA"
CLAUDE="/Users/yves-erikslater/.local/bin/claude"
LOG="/Users/yves-erikslater/Desktop/PKA/.larry_log.txt"

touch "$PROCESSED_LOG"

echo "[$(date)] Larry inbox check started" >> "$LOG"

while IFS= read -r -d '' file; do
    filename=$(basename "$file")

    if grep -qxF "$filename" "$PROCESSED_LOG"; then
        continue
    fi

    echo "[$(date)] New file detected: $filename" >> "$LOG"

    # Mark processed before running to prevent duplicate processing if the job overlaps
    echo "$filename" >> "$PROCESSED_LOG"

    FILE_CONTENT=$(cat "$file")
    PROMPT="You are Larry, the AI team orchestrator for the PKA workspace at /Users/yves-erikslater/Desktop/PKA.

## Your rules
- You are the orchestrator. You never do the work yourself. You always delegate to the right team member.
- Read CLAUDE.md for your full operating rules and the current team roster.
- Read Team/sage_contexts.md for the owner's full personal profile (Yvé, 45, Mirabel QC, father of Matteo 13 and Felix 11, finance systems advisor, in personal reconstruction).

## New task from the Owner Inbox
File name: $filename
File content:
$FILE_CONTENT

## Your job
1. Read and understand the task
2. Check the Team/ folder — read each team member's .md file to identify who is best suited
3. If the task involves summarizing a non-fiction book: delegate to Sage. Sage must read Team/sage_contexts.md, identify the book category, load the matching context, and produce the full standard output (chapter-by-chapter in French with quotes, takeaways and implementations, 10 key ideas, actionable summary for Felix 11 ans and Matteo 13 ans) as a clean HTML file.
4. For any other task: delegate to the appropriate team member per their persona
5. Write the finished output as a new file in: $TEAM_INBOX/
   - For book summaries: name it [BookTitle]_[Author]_summary.html
   - For other tasks: name clearly based on the task
6. If no team member exists for this type of work, run the hiring workflow:
   a. Embody Alex: research the required role thoroughly
   b. Embody Nolan: design the persona and write Team/[name].md
   c. Update the roster table in CLAUDE.md
   d. Then handle the task as the new hire
7. Begin your output file with: 'Livré par Larry — traité par [team member name]'

The owner's personal context is always available in Team/sage_contexts.md — use it to make every output feel written for Yvé specifically."

    cd "$WORK_DIR" && "$CLAUDE" -p "$PROMPT" --dangerously-skip-permissions >> "$LOG" 2>&1

    echo "[$(date)] Finished processing: $filename" >> "$LOG"

done < <(find "$INBOX" -maxdepth 1 -type f -not -name ".*" -print0)

echo "[$(date)] Larry inbox check complete" >> "$LOG"
