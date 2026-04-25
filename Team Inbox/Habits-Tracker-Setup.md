# Daily Habits Tracker — Ready to Use

**From:** Jordan (Productivity Coach) + Finn (Personal Productivity Developer)  
**Date:** 2026-04-25  
**Updated:** 2026-04-25 (added 4 new habits)  
**Status:** Live — start logging today

---

## Quick Start (30 seconds)

1. **Open the tracker:** `open /Users/yves-erikslater/Desktop/PKA/habits_tracker.html`
2. **Check off what you did today** (or didn't)
3. **Click "Save to Database"**
4. **Done.** Takes 25 seconds.

---

## The System

**Jordan's Design:**

You're not tracking to be perfect. You're tracking to *understand which habits are actually viable for you* and which ones are aspirational. The data will show:
- Which habits stick naturally (you do them without thinking)
- Which habits consistently break (the pattern is clear)

This distinction is crucial. Some habits might need to be redesigned or abandoned. Others might need more support. The tracking reveals the truth.

**Pick one anchor time each day** (breakfast, end of day, before bed) where you log. Same time = it becomes routine, not a decision.

---

## What You're Tracking (19 habits daily)

### Essential Habits (16) — ★
| Category | Habits |
|----------|--------|
| **Sleep & Recovery** | Sommeil (Sleep), Consommation eau (Water) |
| **Mindfulness** | Méditation, Plan (daily planning) |
| **Productivity** | Journal, Lecture (Reading), Big P (personal project), Big W (work project) |
| **Physical** | Étirements, Cardio, Weightlifting, Protéines/Bouffe |
| **Connection** | QT Friends, QT Matteo, QT Felix, QT Girlfriend |

### Optional Habits (3) — (opt)
- Nouvelle recette (Try a new recipe)
- Pratique guitare ou piano (Guitar or piano practice)
- Rangement-menage (Tidying/cleaning)

Each habit is binary: done or not done. No grey zone.

**The distinction:** Essential habits are your core daily commitments. Optional habits are nice-to-haves. The tracker shows both, but you'll likely see different success rates — that's the insight you're looking for.

---

## Weekly Diagnostic

Every Sunday, run this command to see the pattern:

```bash
python3 /Users/yves-erikslater/Desktop/PKA/scripts/habits_tracker.py --weekly
```

This shows you:
- Which habits you hit consistently (80%+ success)
- Which habits are struggling (40% or less)
- The overall trajectory

Use this data to talk with Leo (motivation), Blake (training), or Camille (patterns) about what needs redesigning.

---

## The Rules

1. **Check off as you go, or review at your anchor time.** Not both.
2. **No guilt on misses.** The point is *data*, not shame.
3. **Weekly review, not daily guilt.** You look at the pattern, not beat yourself up.
4. **Honest tracking.** If you didn't do it, you didn't do it. The data is only useful if it's real.

---

## What This Is NOT

- Not a way to judge yourself
- Not a shame mechanism
- Not another thing to fail at
- Not proof you need more willpower

It's a **diagnostic tool**. The goal: understand the actual Yvé so we can design systems that work for him — not force him into a mold that doesn't fit.

---

## Storage

Data is saved in two places:
- **Browser localStorage** (backup, immediate)
- **PKA.db** (persistent database, once the Python backend is connected)

You can always see your raw data and export it later.

---

## Next Steps

1. **Start logging today** (open the HTML file, check off what you did)
2. **Same time each day** for 1 week
3. **Sunday: Run the weekly report** to see the pattern
4. **Share with Jordan** if something isn't working or feels off

---

*Tracker deployed: 2026-04-25 | Designed by Jordan + Finn | Backed by PKA.db*
