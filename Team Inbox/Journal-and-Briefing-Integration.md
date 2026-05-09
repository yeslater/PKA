# Journal & Daily Briefing Integration

## How It Works

Every day at **4:30 AM**, the Daily Team Briefing routine automatically:

1. **Reads your journal entry from yesterday** (if it exists)
2. **Generates two types of responses:**
   - **Daily Briefing** — 7 cluster paragraphs with general guidance for today
   - **Journal Responses** — 7 cluster paragraphs with specific feedback *about what you wrote*

3. **Saves three files:**
   - `Daily-Briefing-YYYY-MM-DD.html` — HTML email preview of the briefing
   - `Journal-Responses-YYYY-MM-DD.json` — JSON file with responses specific to your journal entry
   - Gmail draft — Briefing sent as draft email to your inbox

---

## Using the Journal

### Writing an Entry

1. Open `journal.html` in your browser
2. Use the date picker to select today's date (or use Prev/Next/Today buttons)
3. Write your entry in the main text area
4. **Auto-saves every 2 seconds** — no need to manually save
5. View previous entries by clicking on them in the sidebar

### Loading Team Responses

**Option A: Drag & Drop**
1. After the routine runs (4:30 AM), find the `Journal-Responses-YYYY-MM-DD.json` file in Team Inbox
2. Drag and drop it onto the "Team Responses" panel on the right side of the journal
3. Responses load instantly

**Option B: Click to Select**
1. Click the "📂 Drop responses file here" area
2. Select the `Journal-Responses-YYYY-MM-DD.json` file from your computer
3. Responses load and display

### Viewing Responses

- Once loaded, responses are stored locally in your browser
- They appear in the right panel organized by cluster
- Each cluster response is specific to what you wrote in your journal that day
- Responses persist until you clear browser storage

---

## What Team Responses Look Like

The team reads your journal entry and gives you cluster-specific feedback:

- **Mind & Inner Life** — Validation, emotional perspective
- **Physical Health** — Suggestions based on what you shared about your body/energy
- **Productivity** — Ideas about your execution patterns
- **Work & Career** — Perspective on your professional challenges
- **Relationships** — Support on connection and communication
- **Parenting** — Feedback on how you're showing up for Matteo and Felix
- **Personal Identity** — Guidance on who you're becoming

Each response acknowledges what you actually wrote, not generic advice.

---

## The Daily Briefing

The briefing is *different* from journal responses. It:
- Runs at **4:30 AM** every day
- Provides general guidance for the day ahead
- References your habits and current challenges
- Is motivating, funny, and grounded in your real situation

It's saved as both:
- HTML (viewable in browser)
- Gmail draft (automatically in your inbox)

---

## File Organization

```
Team Inbox/
├── Daily-Briefing-2026-04-27.html          (HTML preview)
├── Journal-Responses-2026-04-27.json       (Load into journal)
├── Daily-Briefing-2026-04-26.html
├── Journal-Responses-2026-04-26.json
└── ... (one set per day)
```

---

## Syncing with GitHub

The routine commits all files to your GitHub repo (`https://github.com/yeslater/PKA`), so you have:
- Cloud backup of all responses
- Version history
- Access from any device

---

## Tips

1. **Write honestly.** The team responds best to real, specific entries
2. **Read the briefing in the morning.** It's timed for 4:30 AM to be ready when you wake up
3. **Load responses after writing.** Once the routine runs, load the JSON file to see personalized feedback
4. **Use both together:** Journaling + briefing + habit tracking = complete daily system

---

*Last updated: 2026-04-26*
