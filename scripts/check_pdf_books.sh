#!/bin/bash

PDF_INPUT="/Users/yves-erikslater/Desktop/PKA/PDF Book Input"
PDF_OUTPUT="/Users/yves-erikslater/Desktop/PKA/PDF Book Output"
PROCESSED_LOG="/Users/yves-erikslater/Desktop/PKA/.processed_pdfs.txt"
WORK_DIR="/Users/yves-erikslater/Desktop/PKA"
GEMINI="/Users/yves-erikslater/.local/bin/gemini"
CLAUDE_SCRIPT="/Users/yves-erikslater/Desktop/PKA/scripts/claude_book_summary.py"
LOG="/Users/yves-erikslater/Desktop/PKA/.larry_log.txt"
CONFIG_FILE="/Users/yves-erikslater/Desktop/PKA/.book_summary_config"

# Parse command-line arguments
ADULT_ONLY=0
USE_MODEL="gemini"  # default

# Check config file for default model preference
if [ -f "$CONFIG_FILE" ]; then
    CONFIG_MODEL=$(grep -o '"defaultModel": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    if [ -n "$CONFIG_MODEL" ]; then
        USE_MODEL="$CONFIG_MODEL"
    fi
fi

# Command-line arguments override config
while [ $# -gt 0 ]; do
    case "$1" in
        --adult-only)
            ADULT_ONLY=1
            ;;
        --claude)
            USE_MODEL="claude"
            ;;
        --gemini)
            USE_MODEL="gemini"
            ;;
    esac
    shift
done

touch "$PROCESSED_LOG"

# Function to execute with Gemini
execute_with_gemini() {
    local pdf_file="$1"
    local prompt="$2"
    local output_file="$3"

    cd "$WORK_DIR" && "$GEMINI" -p "$prompt" --dangerously-skip-permissions > "$output_file" 2>> "$LOG"

    # Remove markdown blocks if returned
    sed -i '' -e 's/^```html//g' -e 's/^```//g' "$output_file"
}

# Function to execute with Claude
execute_with_claude() {
    local pdf_file="$1"
    local prompt="$2"
    local output_file="$3"

    cd "$WORK_DIR" && "$WORK_DIR/.venv/bin/python3" "$CLAUDE_SCRIPT" "$pdf_file" "$prompt" "$output_file" 2>> "$LOG"
}

echo "[$(date)] Sage PDF book check started (using $USE_MODEL)" >> "$LOG"

while IFS= read -r -d '' file; do
    filename=$(basename "$file")

    if grep -qxF "$filename" "$PROCESSED_LOG"; then
        continue
    fi

    echo "[$(date)] New PDF detected: $filename" >> "$LOG"
    
    # Base name for creating output files
    BASENAME=$(basename "$file" .pdf | sed -e 's/[^A-Za-z0-9._-]/_/g')

    # ==========================================
    # 1. ADULT PROMPT
    # ==========================================
    PROMPT_ADULT="Tu es Sage, le résumeur de livres non-fictifs de l'équipe PKA.

## Étape 1 — Lis le contexte
Lis d'abord ces deux fichiers avant de commencer :
- Team/owner_context.md — le profil complet d'Yvé (ton lecteur)
- Team/sage_contexts.md — les 10 contextes par catégorie de livre

## Étape 2 — Lis le livre
Le fichier PDF se trouve ici : $file

Lis-le en entier. Identifie le titre exact, l'auteur, la catégorie principale, et la thèse centrale. Charge le contexte correspondant.

## Étape 3 — Produis le résumé complet en HTML

Génère une page HTML complète et valide pour Yvé, entièrement en français :

### SECTION 1 — RÉSUMÉ CHAPITRE PAR CHAPITRE
Pour chaque chapitre : Titre, résumé en 2-3 phrases, 5 citations marquantes, et Top 5 idées clés (avec 'Comment le mettre en pratique' pour Yvé).

### SECTION 2 — LES 10 IDÉES LES PLUS IMPORTANTES DU LIVRE
Liste numérotée des 10 idées les plus importantes contextualisées pour Yvé.

### SECTION 3 — COMPARAISON AVEC DES LIVRES SIMILAIRES
Compare avec 3 à 5 livres pertinents.

### SECTION 4 — CE QUE CE LIVRE CHANGE POUR VOUS
5 à 7 recadrages significatifs.

### SECTION 5 — CE QUE VOUS POUVEZ FAIRE DIFFÉREMMENT
8 à 12 actions concrètes et spécifiques pour Yvé.

### SECTION 6 — 30 QUESTIONS SUR LES CONCEPTS CLÉS
Génère une liste de 30 questions portant sur les concepts les plus importants du livre pour tester la compréhension et stimuler la réflexion d'Yvé.

## Exigences HTML
- Page HTML complète et valide avec <head> (charset UTF-8, titre)
- Utilise EXACTEMENT ce bloc CSS dans ta balise <style> :
[DEBUT DU BLOC CSS]
    :root { --primary: #2c3e50; --accent: #e67e22; --accent-light: #fdf2e9; --teal: #16a085; --teal-light: #e8f8f5; --purple: #8e44ad; --purple-light: #f5eef8; --red: #c0392b; --red-light: #fdedec; --blue: #2980b9; --blue-light: #ebf5fb; --green: #27ae60; --green-light: #eafaf1; --gray: #7f8c8d; --gray-light: #f8f9fa; --border: #e8e8e8; --text: #2d3436; --text-light: #636e72; }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Georgia, 'Times New Roman', serif; font-size: 17px; line-height: 1.75; color: var(--text); background: #fafafa; }
    .page-header { background: linear-gradient(135deg, var(--primary) 0%, #34495e 100%); color: white; padding: 50px 40px 40px; text-align: center; }
    .page-header h1 { font-size: 2.2rem; font-weight: 700; margin-bottom: 10px; line-height: 1.3; }
    .page-header .author { font-size: 1.2rem; color: #bdc3c7; margin-bottom: 18px; font-style: italic; }
    .page-header .thesis { font-size: 1.05rem; color: #ecf0f1; max-width: 750px; margin: 0 auto; font-style: italic; border-top: 1px solid rgba(255,255,255,0.2); padding-top: 18px; line-height: 1.6; }
    .container { max-width: 920px; margin: 0 auto; padding: 40px 30px; }
    .toc { background: white; border: 1px solid var(--border); border-radius: 10px; padding: 28px 32px; margin-bottom: 48px; }
    .toc h2 { font-size: 1.1rem; color: var(--primary); margin-bottom: 14px; text-transform: uppercase; letter-spacing: 0.05em; font-family: 'Helvetica Neue', Arial, sans-serif; }
    .toc ol { columns: 2; gap: 20px; padding-left: 18px; }
    .toc li { font-size: 0.92rem; color: var(--blue); margin-bottom: 6px; font-family: 'Helvetica Neue', Arial, sans-serif; }
    .toc a { color: var(--blue); text-decoration: none; }
    .toc a:hover { text-decoration: underline; }
    .section-title { font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 1.5rem; font-weight: 700; color: white; background: var(--primary); padding: 16px 24px; border-radius: 8px 8px 0 0; margin-top: 56px; }
    .section-title .part-label { font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.08em; color: #bdc3c7; display: block; margin-bottom: 4px; }
    .chapter-block { background: white; border: 1px solid var(--border); border-top: none; border-radius: 0 0 8px 8px; padding: 32px; margin-bottom: 8px; }
    .chapter-summary { font-size: 1rem; color: var(--text); margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid var(--border); }
    blockquote { border-left: 4px solid var(--accent); background: var(--accent-light); padding: 14px 20px; margin: 12px 0; border-radius: 0 6px 6px 0; font-style: italic; color: #5d4037; font-size: 0.97rem; line-height: 1.65; }
    .quotes-title { font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.06em; color: var(--gray); margin: 24px 0 10px; }
    .ideas-grid { display: flex; flex-direction: column; gap: 16px; margin-top: 24px; }
    .idea-card { background: var(--gray-light); border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }
    .idea-header { background: var(--teal); color: white; padding: 10px 16px; font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 0.95rem; font-weight: 600; }
    .idea-body { padding: 14px 16px 6px; font-size: 0.96rem; }
    .idea-practice { background: #fff9e6; border-top: 1px dashed #f0c040; padding: 12px 16px; margin-top: 10px; font-size: 0.93rem; color: #5d4037; }
    .idea-practice strong { color: var(--accent); font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.04em; display: block; margin-bottom: 4px; }
    .top10-section { background: white; border: 2px solid var(--primary); border-radius: 10px; padding: 36px; margin: 48px 0; }
    .top10-section h2 { font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 1.4rem; color: var(--primary); margin-bottom: 24px; padding-bottom: 12px; border-bottom: 2px solid var(--primary); }
    .top10-item { display: flex; gap: 16px; padding: 16px 0; border-bottom: 1px solid var(--border); }
    .top10-item:last-child { border-bottom: none; }
    .top10-num { background: var(--primary); color: white; font-family: 'Helvetica Neue', Arial, sans-serif; font-weight: 700; font-size: 1.1rem; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 2px; }
    .top10-content strong { display: block; color: var(--primary); font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 1rem; margin-bottom: 4px; }
    .top10-content p { font-size: 0.95rem; color: var(--text-light); }
    .tag { display: inline-block; background: var(--accent); color: white; font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 0.78rem; padding: 3px 9px; border-radius: 12px; text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 8px; }
    .big-section-header { font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 1.8rem; color: var(--primary); border-bottom: 3px solid var(--accent); padding-bottom: 10px; margin: 60px 0 30px; }
    .big-section-header .part-label { font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--gray); display: block; margin-bottom: 4px; }
    .back-to-top { display: block; text-align: right; margin-top: 20px; font-size: 0.9rem; color: var(--accent); text-decoration: none; font-weight: bold; }
    .back-to-top:hover { text-decoration: underline; }
    footer { background: var(--primary); color: #95a5a6; text-align: center; padding: 20px; font-family: 'Helvetica Neue', Arial, sans-serif; font-size: 0.85rem; margin-top: 60px; }
    @media (max-width: 640px) { .toc ol { columns: 1; } .page-header h1 { font-size: 1.5rem; } .container { padding: 24px 16px; } }
[FIN DU BLOC CSS]
- Ne renvoie QUE du HTML valide (pas de balises markdown de bloc de code \`\`\`html).
- Ajoute un lien '<a href="#toc" class="back-to-top">↑ Retour à la table des matières</a>' à la fin de chaque section, et assure-toi que la table des matières a bien l'attribut id="toc"."

    # ==========================================
    # 2. KIDS PROMPT (Base)
    # ==========================================
    KIDS_BASE="Le fichier PDF se trouve ici : $file
Lis-le en entier.
Ta mission est de produire un résumé interactif complet en HTML, entièrement et exclusivement rédigé en français du début à la fin — aucun mot en anglais nulle part (ni dans le contenu, ni dans les boutons, ni dans les labels, ni dans les messages du quiz).
Tout dans un seul fichier HTML autonome. Ne renvoie QUE le code HTML, pas de blocs markdown.

Structure-le exactement comme ceci :

1. C'est quoi ce livre ? (4 phrases maximum)
Langage simple et dynamique. Pas de ton ennuyeux de manuel scolaire. Écris comme un grand ami enthousiaste qui vient de le lire et veut en parler.

2. Les Grands Thèmes
Identifie 6 à 8 grands thèmes du livre. Pour chaque thème, crée :
- Un emoji amusant et une accroche en une ligne qu'un enfant trouverait cool
- Une explication du thème en 3 à 4 phrases simples
- 3 vraies citations du livre avec le nom de la personne et ce qu'elle a accompli
- Une boîte 'Ce que ça veut dire pour toi' — une action ou une réflexion écrite directement à lui.
Présente-les sous forme de sections normales et claires en HTML (n'utilise PAS de balises <details> ou <summary>, utilise simplement des divs stylisées).

3. Les 5 Leçons les Plus Importantes
Numérote-les de 01 à 05. Pour chacune :
- Un titre percutant en gras
- Une explication de 4 à 6 phrases avec de vrais exemples tirés du livre
- Relie chaque leçon à quelque chose qu'il connaît bien.

4. Grand Quiz — 20 Questions
Choix multiples, 3 options chacune, basées sur les concepts les plus importants du livre. Une seule bonne réponse. Utilise les classes HTML du quiz fournies ci-dessous. EXEMPLE HTML:
<div class=\"quiz-question\">
  <h3>Question 1...</h3>
  <button class=\"quiz-btn\" onclick=\"checkAnswer(this, true, 'Bravo ! Explication...')\">Réponse A</button>
  <button class=\"quiz-btn\" onclick=\"checkAnswer(this, false, 'Non, explication...')\">Réponse B</button>
  <div class=\"feedback\"></div>
</div>
<div id=\"final-score\"></div>

5. Mots à Connaître
Liste 6 à 8 mots difficiles utilisés dans le résumé. Donne à chacun une définition simple et mémorable pour un enfant.

6. Défis de la Semaine
3 petites activités ou expériences qu'il peut essayer dans la vraie vie cette semaine, inspirées directement des idées du livre.

7. On en Parle ?
3 questions de discussion qu'il peut explorer avec un parent ou un frère — ouvertes, qui font réfléchir.

EXIGENCES DE DESIGN:
- Utilise EXACTEMENT ce bloc HTML/CSS/JS dans ta réponse :
[DEBUT DU BLOC KIDS]
<!DOCTYPE html>
<html lang=\"fr\">
<head>
<meta charset=\"UTF-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
<title>Résumé du Livre</title>
<style>
:root { --bg: #121212; --surface: #1e1e2e; --primary: #ff4757; --primary-hover: #ff6b81; --text: #f1f2f6; --text-muted: #ced6e0; --accent: #3742fa; --success: #2ed573; --error: #ff4757; }
body { background: var(--bg); color: var(--text); font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; margin: 0; padding: 20px; line-height: 1.6; }
h1, h2, h3 { color: var(--primary); font-weight: 800; text-transform: uppercase; letter-spacing: 1px; }
.container { max-width: 800px; margin: auto; }
.header { text-align: center; margin-bottom: 40px; background: linear-gradient(135deg, var(--surface), #2d3436); padding: 30px; border-radius: 15px; border-bottom: 4px solid var(--primary); }
.header h1 { font-size: 2.5em; margin: 0; color: white; }
.section { margin-bottom: 40px; background: var(--surface); padding: 25px; border-radius: 15px; box-shadow: 0 10px 20px rgba(0,0,0,0.3); }
details { background: rgba(55, 66, 250, 0.1); border: 2px solid var(--accent); border-radius: 10px; margin-bottom: 15px; overflow: hidden; transition: all 0.3s; }
summary { padding: 15px 20px; font-weight: bold; cursor: pointer; list-style: none; display: flex; align-items: center; font-size: 1.1em; color: #fff; }
summary:hover { background: rgba(55, 66, 250, 0.2); }
summary::-webkit-details-marker { display: none; }
.details-content { padding: 20px; background: var(--surface); border-top: 1px solid var(--accent); }
.action-box { background: rgba(255, 71, 87, 0.1); border-left: 4px solid var(--primary); padding: 15px; margin-top: 15px; border-radius: 0 10px 10px 0; }
.lesson { display: flex; margin-bottom: 20px; }
.lesson-num { font-size: 2em; font-weight: 900; color: var(--primary); margin-right: 15px; opacity: 0.8; }
.quiz-question { background: rgba(255,255,255,0.05); padding: 20px; border-radius: 10px; margin-bottom: 20px; }
.quiz-btn { background: var(--accent); color: white; border: none; padding: 12px 20px; margin: 8px 0; border-radius: 8px; cursor: pointer; width: 100%; text-align: left; font-size: 1em; font-weight: bold; transition: background 0.2s; }
.quiz-btn:hover { background: #5352ed; }
.feedback { margin-top: 10px; padding: 15px; border-radius: 8px; display: none; font-weight: bold; }
.vocab-word { color: var(--primary); font-weight: bold; font-size: 1.1em; }
.challenge { background: rgba(46, 213, 115, 0.1); border-left: 4px solid var(--success); padding: 15px; margin-bottom: 15px; border-radius: 0 10px 10px 0; }
</style>
<script>
window.quizScore = 0;
window.quizAnswered = 0;
function checkAnswer(btn, isCorrect, explanation) {
  let parent = btn.parentElement;
  let feedback = parent.querySelector('.feedback');
  let buttons = parent.querySelectorAll('.quiz-btn');
  if(buttons[0].disabled) return;
  buttons.forEach(b => b.disabled = true);
  feedback.style.display = 'block';
  feedback.innerHTML = explanation;
  if(isCorrect) {
    btn.style.background = 'var(--success)';
    feedback.style.background = 'rgba(46, 213, 115, 0.2)';
    feedback.style.borderLeft = '4px solid var(--success)';
    window.quizScore++;
  } else {
    btn.style.background = 'var(--error)';
    feedback.style.background = 'rgba(255, 71, 87, 0.2)';
    feedback.style.borderLeft = '4px solid var(--error)';
  }
  window.quizAnswered++;
  if(window.quizAnswered === 20) {
    document.getElementById('final-score').innerHTML = '<h3>Score final : ' + window.quizScore + '/20 !</h3>';
  }
}
</script>
</head>
<body>
<div class=\"container\">
  <!-- Construis le reste de la page HTML ici en utilisant ces classes -->
[FIN DU BLOC KIDS]"

    PROMPT_FELIX="$KIDS_BASE

Conçu spécifiquement pour FELIX (un garçon de 11 ans).
Profil de Felix : créatif, très social, aime les échecs et le ski de fond.
Connecte le vocabulaire, les exemples et les leçons à ces intérêts !"

    PROMPT_MATTEO="$KIDS_BASE

Conçu spécifiquement pour MATTEO (un garçon de 13 ans).
Profil de Matteo : analytique, lecteur vorace, joue de la guitare, passionné de géographie et d'histoire, adore les documentaires, impatient, lutte avec l'autocontrôle.
Parle à son intelligence directement. Connecte aux sciences, histoire, guitare. Adresse l'autocontrôle et la patience avec bienveillance."

    # Select execution function based on model
    if [ "$USE_MODEL" = "claude" ]; then
        EXEC_FUNC="execute_with_claude"
    else
        EXEC_FUNC="execute_with_gemini"
    fi

    # Execute Adult Summary
    echo "[$(date)] Generating Adult summary for: $filename (using $USE_MODEL)" >> "$LOG"
    $EXEC_FUNC "$file" "$PROMPT_ADULT" "$PDF_OUTPUT/${BASENAME}_Adult.html"

    if [ "$ADULT_ONLY" -eq 0 ]; then
        # Execute Felix Summary
        echo "[$(date)] Generating Felix summary for: $filename" >> "$LOG"
        $EXEC_FUNC "$file" "$PROMPT_FELIX" "$PDF_OUTPUT/${BASENAME}_Felix.html"

        # Execute Matteo Summary
        echo "[$(date)] Generating Matteo summary for: $filename" >> "$LOG"
        $EXEC_FUNC "$file" "$PROMPT_MATTEO" "$PDF_OUTPUT/${BASENAME}_Matteo.html"

        echo "[$(date)] Sage completed all 3 summaries for: $filename" >> "$LOG"
    else
        echo "[$(date)] Sage completed Adult summary for: $filename" >> "$LOG"
    fi
    echo "$filename" >> "$PROCESSED_LOG"

done < <(find "$PDF_INPUT" -maxdepth 1 -type f -iname "*.pdf" -print0)

echo "[$(date)] Sage PDF book check complete" >> "$LOG"
