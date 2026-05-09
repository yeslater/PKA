#!/bin/bash

# Generate Daily Leadership Briefing
# This script is designed to run automatically at 4:30 AM.

cd /Users/yves-erikslater/Desktop/PKA || exit 1

TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="Team Inbox/Daily-Briefing-$TODAY.html"
GEMINI="/Users/yves-erikslater/.local/bin/gemini"
LOG=".larry_log.txt"

echo "[$(date)] Generating Daily Briefing for $TODAY" >> "$LOG"

PROMPT="Tu es Larry, l'orchestrateur de l'équipe IA d'Yvé.
Ta mission est de générer le Daily Briefing pour Yvé pour aujourd'hui ($TODAY).

Lis attentivement pour t'imprégner de sa réalité :
1. Team/owner_context.md
2. Team/current-focus.md

Structure ta réponse EXACTEMENT avec ces 7 sections (une pour chaque cluster de l'équipe) :
1. 🧠 Mind & Inner Life (Camille)
2. 🏋️ Physical Health & Performance (Blake)
3. ⚙️ Productivity & Knowledge (Jordan)
4. 💼 Work & Career (Nadia)
5. 🤝 Relationships & Connection (Sofia)
6. 👨‍👦 Parenting & Family (Isabelle)
7. 🧭 Personal Life & Identity (Victor)

POUR CHAQUE CLUSTER, respecte EXACTEMENT ce format :
- 1 ou 2 phrases pour inspirer et encourager.
- Une question de réflexion sur laquelle méditer.
- 2 ou 3 idées à implémenter dans sa vie, accompagnées d'un plan d'action suggéré (concret et immédiat).

Le contenu doit être profondément ancré dans sa réalité actuelle : ses difficultés avec la constance et le doomscrolling, la séparation, la situation de ses fils Matteo et Felix, sa reconstruction, etc.

**Ton unique réponse doit être le code HTML complet de ce briefing.**
- N'inclus PAS de balises Markdown \`\`\`html. Renvoie uniquement le HTML valide, du <!DOCTYPE html> jusqu'à </html>.
- Utilise un design très épuré, élégant et moderne (fond clair ou sombre), avec une belle typographie (system-ui).
- Mets bien en évidence la structure de chaque cluster (Inspiration, Question, Plan d'action).
- Inclus la date du jour ($TODAY) dans le titre ou l'en-tête de la page."

# Execute Gemini CLI to generate the briefing
"$GEMINI" -p "$PROMPT" --dangerously-skip-permissions > "$OUTPUT_FILE" 2>> "$LOG"

# Clean up any potential markdown formatting the LLM might have returned
sed -i '' -e 's/^```html//g' -e 's/^```//g' "$OUTPUT_FILE"

echo "[$(date)] Daily briefing successfully generated at $OUTPUT_FILE" >> "$LOG"
