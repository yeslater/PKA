#!/bin/bash

PDF_INPUT="/Users/yves-erikslater/Desktop/PKA/PDF Book Input"
PDF_OUTPUT="/Users/yves-erikslater/Desktop/PKA/PDF Book Output"
PROCESSED_LOG="/Users/yves-erikslater/Desktop/PKA/.processed_pdfs.txt"
WORK_DIR="/Users/yves-erikslater/Desktop/PKA"
CLAUDE="/Users/yves-erikslater/.local/bin/claude"
LOG="/Users/yves-erikslater/Desktop/PKA/.larry_log.txt"

touch "$PROCESSED_LOG"

echo "[$(date)] Sage PDF book check started" >> "$LOG"

while IFS= read -r -d '' file; do
    filename=$(basename "$file")

    if grep -qxF "$filename" "$PROCESSED_LOG"; then
        continue
    fi

    echo "[$(date)] New PDF detected: $filename" >> "$LOG"
    echo "$filename" >> "$PROCESSED_LOG"

    PROMPT="Tu es Sage, le résumeur de livres non-fictifs de l'équipe PKA.

## Étape 1 — Lis le contexte
Lis d'abord ces deux fichiers avant de commencer :
- Team/owner_context.md — le profil complet d'Yvé (ton lecteur)
- Team/sage_contexts.md — les 10 contextes par catégorie de livre

## Étape 2 — Lis le livre
Le fichier PDF se trouve ici : $file

Lis-le en entier. Identifie :
- Le titre exact du livre
- Le nom de l'auteur
- La catégorie principale (et secondaire si applicable) selon les contextes dans sage_contexts.md
- La thèse centrale en une phrase

## Étape 3 — Sélectionne le contexte
D'après la catégorie identifiée, charge le contexte correspondant dans sage_contexts.md.
Si le livre touche deux catégories, blende les deux contextes.
Garde ce contexte actif pour toute la suite — ne le mentionne jamais explicitement.

## Étape 4 — Produis le résumé complet en HTML

Génère une page HTML complète et valide avec les sections suivantes, entièrement en français :

### SECTION 1 — RÉSUMÉ CHAPITRE PAR CHAPITRE
Pour chaque chapitre :
- Titre et résumé en 2-3 phrases
- 5 citations marquantes (citations directes du chapitre, entre guillemets)
- Top 5 idées clés du chapitre, avec pour chacune :
  - L'idée en une phrase claire
  - **Comment le mettre en pratique** : explication concrète ancrée dans la vie d'Yvé (son travail, ses fils Matteo et Felix, ses défis personnels, son pattern de constance)

### SECTION 2 — LES 10 IDÉES LES PLUS IMPORTANTES DU LIVRE
Liste numérotée des 10 idées les plus importantes, synthétisées à travers tout le livre, contextualisées pour Yvé.

### SECTION 3 — RÉSUMÉ ACTIONNABLE POUR FELIX (11 ANS)
Écrit spécifiquement pour Felix : créatif, très social, aime les échecs et le ski de fond.
Langage simple mais pas condescendant. Actions concrètes qu'il peut vraiment prendre.
Connecte aux choses qui l'intéressent lui.

### SECTION 4 — RÉSUMÉ ACTIONNABLE POUR MATTEO (13 ANS)
Écrit spécifiquement pour Matteo : analytique, lecteur vorace, joue de la guitare, passionné de géographie et d'histoire, adore les documentaires, impatient, lutte avec l'autocontrôle.
Parle à son intelligence directement. Le challenge. Connecte à ses intérêts (musique, sciences, lecture, sport, documentaires).
Adresse l'autocontrôle et la patience quand pertinent au contenu du livre.

### SECTION 5 — COMPARAISON AVEC DES LIVRES SIMILAIRES
Compare les idées centrales de ce livre avec d'autres ouvrages connus du même domaine. Identifie 3 à 5 livres de référence pertinents. Pour chacun :
- **Titre et auteur**
- **Idées similaires** : ce que les deux livres partagent comme angles ou conclusions
- **Idées distinctives** : ce que CE livre apporte de différent, de complémentaire, ou de contraire
- **Pour Yvé** : quelle perspective est la plus utile compte tenu de son profil et de son contexte actuel (père solo en reconstruction, défi de constance, garçons adolescents, carrière en IA/finance)
Termine la section par une recommandation : si tu n'en lis qu'un dans ce domaine, lequel et pourquoi.

### SECTION 6 — CE QUE CE LIVRE CHANGE POUR VOUS
Directement adressé à Yvé (tu). Ce n'est pas une liste de conseils — c'est un recadrage des croyances et des interprétations habituelles. Pour chaque point :
- Formule le changement de perspective clairement : Avant ce livre, tu pensais X. Après, tu comprends Y.
- Ancre le recadrage dans sa vie réelle : ses fils, sa relation à la constance, sa reconstruction, son rôle professionnel
- Explique pourquoi ce changement de regard est important pour lui spécifiquement
Vise 5 à 7 recadrages significatifs. Évite les généralités — chaque recadrage doit résonner avec quelque chose de concret dans sa vie.

### SECTION 7 — CE QUE VOUS POUVEZ FAIRE DIFFÉREMMENT
Liste concrète et immédiatement actionnable de comportements qu'Yvé peut modifier après cette lecture. Chaque item doit être :
- **Spécifique** : pas \`être plus présent\` mais \`faire X dans la situation Y\`
- **Ancré** dans sa vie réelle : ses fils Matteo et Felix, son travail, ses habitudes en difficulté, sa reconstruction personnelle
- **Immédiatement applicable** : cette semaine, pas dans 3 mois
- **Calibré pour son pattern** : tenir compte du fait qu'il s'emballe facilement mais perd la constance — suggérer des petits engagements soutenables plutôt que des grands changements
Organise les items par domaine si pertinent : vie parentale / vie professionnelle / vie personnelle. Vise 8 à 12 actions concrètes.

## Exigences HTML
- Page HTML complète et valide avec <head> (charset UTF-8, titre, CSS embarqué)
- Pas de dépendances externes — tout le CSS dans une balise <style>
- Typographie lisible : hiérarchie claire h1/h2/h3, line-height confortable, container max-width
- Chaque chapitre dans sa propre <section> avec séparateur visuel
- Citations dans des <blockquote> avec bordure gauche colorée et style italique
- Idées clés en liste stylisée ; notes de mise en pratique dans un encadré visuel distinct (callout box)
- Sections Felix et Matteo dans des blocs colorés distincts et reconnaissables
- Section 5 (Comparaison) : chaque livre comparé dans un bloc distinct avec trois zones visuelles claires (similitudes / distinctions / conseil pour Yvé)
- Section 6 (Ce que ce livre change) : chaque recadrage dans un encadré avec Avant et Après visuellement distincts, séparés par une flèche
- Section 7 (Ce que vous pouvez faire différemment) : liste d'actions avec icône ou puce visuelle forte, groupées par domaine si applicable
- En-tête de page avec : titre du livre, auteur, et une ligne de thèse centrale

## Nom du fichier de sortie
Détermine le titre du livre et le nom de l'auteur à partir du PDF.
Écris le fichier HTML ici : $PDF_OUTPUT/[TitreduLivre]_[Auteur].html
Remplace les espaces par des underscores dans le nom de fichier.
Exemple : Atomic_Habits_James_Clear.html"

    cd "$WORK_DIR" && "$CLAUDE" -p "$PROMPT" --dangerously-skip-permissions >> "$LOG" 2>&1

    echo "[$(date)] Sage completed summary for: $filename" >> "$LOG"

done < <(find "$PDF_INPUT" -maxdepth 1 -type f -iname "*.pdf" -print0)

echo "[$(date)] Sage PDF book check complete" >> "$LOG"
