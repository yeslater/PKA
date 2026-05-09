# Knowledge Base — Personal Information Collection System

Store and organize everything you learn: quotes, ideas, websites, videos, articles, books, and more.

---

## Quick Start

1. **Open:** `knowledge_base.html` in your browser
2. **Add entry:** Click "+ Add Entry" button
3. **Fill in:** Title, type, category, URL (optional), description, tags
4. **Save:** Click "Save Entry"
5. **Search/Filter:** Use search box or filter by type/category
6. **Edit/Delete:** Click Edit or Delete on any card

---

## Entry Types

Choose the type that fits what you're storing:

- **Idea** — Original thoughts, concepts, insights
- **Quote** — Memorable quotes from people, books, articles
- **Website** — Useful websites and links to bookmark
- **Video** — Video links and summaries
- **Article** — Article links and notes
- **Book** — Book references and summaries
- **Other** — Anything else

---

## How to Use

### Adding an Entry

1. Click **"+ Add Entry"** in the sidebar
2. Fill in the form:
   - **Title** — What is this? (required)
   - **Type** — Quote, Idea, Website, etc.
   - **Category** — Organize by topic (Business, Life, AI, etc.)
   - **URL** — Link to the source (optional but recommended for websites/videos)
   - **Description** — The actual quote, idea, notes, or summary
     - ✓ Plain text
     - ✓ **HTML supported** — Paste formatted content, code, lists, links
   - **Tags** — Comma-separated keywords for easy search

3. Click **"Save Entry"**

#### HTML Support in Descriptions

You can paste **HTML** directly into the Description field:

**Supported HTML elements:**
- Paragraphs: `<p>text</p>`
- Lists: `<ul><li>item</li></ul>` and `<ol><li>item</li></ol>`
- Links: `<a href="url">text</a>`
- Bold/Italic: `<strong>text</strong>`, `<em>text</em>`
- Code: `<code>text</code>`, `<pre><code>code block</code></pre>`
- Blockquotes: `<blockquote>quote</blockquote>`
- Images: `<img src="url" alt="description">`
- Line breaks: `<br>`

**Examples:**

```html
<p>Here's a great idea:</p>
<ul>
  <li>Point one</li>
  <li>Point two with <strong>emphasis</strong></li>
</ul>
<p>Learn more: <a href="https://example.com">link</a></p>
```

Or paste formatted HTML from a website:
1. Copy formatted content from any website
2. Paste into the Description field
3. Save — it will display as formatted content

**Security Note:** The system sanitizes HTML to remove scripts. Only paste HTML from trusted sources.

### Searching

Type in the **search box** at the top for smart searching with advanced operators.

#### Basic Search
Type words to find entries containing them (searches titles, descriptions, tags):
- `ai` — Find entries mentioning AI
- `learning habits` — Find entries with both "learning" AND "habits"

#### Advanced Operators

**Exact Phrases** — Use quotes
```
"machine learning" — Find exact phrase (case-insensitive)
```

**Exclude Words** — Use minus sign
```
ai -old — Find "ai" but NOT "old"
habits -skip — Find "habits" excluding entries with "skip"
```

**Search Specific Fields** — Use field names
```
title:ai — Search in titles only
desc:learning — Search in descriptions only
tag:urgent — Search in tags only
```

**Filter by Type or Category**
```
type:quote — Show only quotes
type:website — Show only websites
cat:business — Show only Business category
```

**Combine Operators**
```
title:ai -old tag:learning — AI in title, no "old", tagged "learning"
"machine learning" type:article — Exact phrase articles only
-skip -done tag:actionable — Actionable items, excluding "skip" and "done"
```

#### Fuzzy Matching
The search automatically handles typos and similar words:
- Search for `learnign` → finds `learning`
- Search for `ai` → finds `AI`, `artificial intelligence`
- Works with up to 2-character differences

### Filtering

**By Type:**
- Click "All Entries" to see everything
- Or click a type: Quotes, Ideas, Websites, Videos, Articles, Books, Other

**By Category:**
- Click a category name in the sidebar
- Categories auto-populate as you add entries
- Click again to toggle off

**By Tags:**
- Click a tag in the sidebar under "Tags" section
- Tags auto-populate as you add entries
- Click multiple tags to show entries with ANY of those tags
- Click again to toggle a tag off
- **Tip:** Click tags directly on entry cards for quick filtering

### Editing Entries

1. Find the entry
2. Click **"Edit"** button
3. Update any field
4. Click **"Save Entry"**

### Duplicating Entries

1. Find the entry
2. Click **"Duplicate"** button
3. A copy is created with " (copy)" added to title
4. Edit the copy as needed

### Deleting Entries

**Single Delete:**
1. Find the entry
2. Click **"Delete"**
3. Confirm deletion

**Batch Delete:**
1. Check the **checkbox** on entries you want to delete
2. Click **"Delete Selected"** button (appears when items are selected)
3. Confirm deletion
4. All selected entries deleted at once

### Sorting

Click the **Sort** dropdown in the top right to change how entries are ordered:

- **Newest First** — Recently added entries at top
- **Oldest First** — Oldest entries at top
- **Title (A-Z)** — Alphabetical by title
- **Title (Z-A)** — Reverse alphabetical
- **By Type** — Grouped by entry type
- **By Category** — Grouped by category

### Batch Operations

When you select entries (check the boxes):

- **Select All** — Check all visible entries
- **Clear** — Uncheck all selections
- **Delete Selected** — Delete all checked entries at once
- Selection counter shows how many are selected

---

## Organization Strategy

### By Category

Create categories that make sense for you:
- **Business** — Career, entrepreneurship, management
- **Learning** — Education, courses, skills
- **Life** — Personal development, habits, philosophy
- **AI** — AI tools, concepts, applications
- **Projects** — Ideas for your projects
- **People** — Important contacts, notes about people
- **Books** — Book summaries and reviews
- **Inspiration** — Motivational quotes and ideas

### By Tags

Use tags to cross-reference across categories:
- `urgent` — Things you need to act on
- `reference` — Reference material for later
- `important` — Key insights
- `actionable` — Ideas to implement
- `research` — Needs more research
- `project-name` — Related to a specific project

### Example Entry

**Type:** Quote  
**Title:** On Consistency and Excellence  
**Category:** Life  
**URL:** (empty)  
**Description:** "We are what we repeatedly do. Excellence, then, is not an act, but a habit." — Aristotle  
**Tags:** consistency, excellence, habits, philosophy

---

## Features

✓ **Search** — Find entries by title, description, or tags  
✓ **Filter** — By type (Quote, Idea, Website, etc.) and category  
✓ **Edit** — Update any entry anytime  
✓ **Delete** — Remove entries you no longer need  
✓ **Tags** — Multiple tags per entry for cross-referencing  
✓ **Export** — Download all entries as JSON backup  
✓ **Offline** — Works completely offline, stored in browser  
✓ **Responsive** — Works on desktop, tablet, and mobile  

---

## Data Export

Click **"📥 Export"** button to download all your entries as a JSON file.

- **When:** Do this regularly (weekly) for backup
- **What:** Creates `knowledge-base-YYYY-MM-DD.json` file
- **Use:** Keep as backup or import into another system

---

## Tag System

Tags are powerful for organizing across categories:

### Tag Types

- **Project tags** — `project-pka`, `project-career`, `project-home`
- **Status tags** — `urgent`, `important`, `reference`, `actionable`
- **Topic tags** — `ai`, `leadership`, `habits`, `learning`
- **Action tags** — `implement`, `review`, `research`, `follow-up`
- **Source tags** — `book`, `podcast`, `conversation`, `course`

### Tag Filtering

- **Click tags in sidebar** to filter by that tag
- **Click tags on entry cards** for quick filtering
- **Select multiple tags** to see entries with ANY of those tags
- **Combine with type/category filters** for precise searching

### Example Tag Usage

Entry with multiple tags:
```
Title: The Lean Startup
Tags: lean, startup, methodology, business, reference, project-pka
```

Now you can find this entry by clicking:
- `#lean` in tags sidebar
- `#startup` in tags sidebar
- `#project-pka` to see all entries related to this project
- `#reference` to see all reference materials

---

## Tips

1. **Be specific with titles.** Search will be better if titles are descriptive.

2. **Use tags liberally.** Tags make it easy to find related entries across categories.

3. **Use project-based tags.** Tag entries related to each active project with `project-name`.

4. **Create status tags.** Use `urgent`, `important`, `actionable` to mark priority entries.

5. **Include sources.** For websites and articles, keep the URL so you can return to the original.

6. **Regular cleanup.** Review entries monthly and delete outdated ones.

7. **Summarize videos.** When adding a video, write a 1-2 sentence summary in the description.

8. **Click tags directly.** You can click any tag on an entry card to filter by that tag instantly.

---

## Storage

- All data stored in your **browser's localStorage**
- No data sent to servers
- Private and offline
- Persists between sessions
- Export regularly for backup

---

## Search Examples

### Find All Business Quotes
```
type:quote cat:business
```
Shows: All quotes in the Business category

### Find Actionable Ideas (Not Done)
```
type:idea tag:actionable -done
```
Shows: Ideas tagged as actionable, excluding those marked "done"

### Find Learning Resources
```
tag:learning -skip title:course
```
Shows: Entries tagged "learning" with "course" in title, excluding "skip" items

### Find Your AI Research
```
"machine learning" -old tag:research
```
Shows: Entries with "machine learning" phrase, tagged "research", excluding old items

### Find Important Business Articles
```
type:article cat:business tag:important
```
Shows: All important articles in the Business category

---

## Examples

### Website Entry
```
Type: Website
Title: The Lean Startup Resources
Category: Business
URL: https://theleanstartup.com
Description: Resource hub for lean methodology, MVP development, and continuous deployment. Good for referencing principles of validated learning.
Tags: lean, startup, methodology, reference
```

### Quote Entry
```
Type: Quote
Title: On Progress
Category: Life
URL: (empty)
Description: "Progress is not a straight line. It's a spiral. You will revisit lessons and challenges at deeper levels." — Unknown
Tags: progress, growth, mindset, motivation
```

### Idea Entry
```
Type: Idea
Title: Habit Tracker with AI Coaching
Category: Projects
URL: (empty)
Description: Build a personal system that tracks daily habits and generates AI-powered coaching from different personas. Could integrate with journaling and goal tracking. Helps identify sustainable habits vs aspirational ones.
Tags: project-pka, habits, ai, coaching, actionable
```

---

## Keyboard Shortcuts (Coming Soon)

- `Ctrl+K` — Open quick search
- `Ctrl+N` — New entry
- `Esc` — Close modal

---

*Created: 2026-04-26*
