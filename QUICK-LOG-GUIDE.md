# Quick Habit Log — iPhone Voice Commands

Log your daily habits in seconds via the Gemini iPhone app.

---

## How to Use

### On Gemini iPhone App:

1. **Say or type one of these:**
   ```
   Run: python3 /Users/yves-erikslater/Desktop/PKA/scripts/quick_habit_log.py "Sommeil 1, Cardio 1, Méditation 0, Lecture 1"
   ```

2. **Gemini executes and returns:**
   ```
   ✓ Today logged: 4/18 essential habits
   📊 Daily Score: 22/100
   ✓ Completed: Sommeil, Cardio, Lecture
   ```

That's it. Your habits are saved and scored.

---

## Input Formats

### Format 1: Full Names with Values
```
"Sommeil 1, Cardio 1, Méditation 0, Lecture 1, Plan 0, Étirements 1"
```

### Format 2: Abbreviations (Fastest for Voice)
```
"S1 C1 M0 J1 P0 E1"
```

**Abbreviations:**
- **S** = Sommeil (Sleep)
- **M** = Méditation
- **P** = Plan
- **J** = Journal
- **L** = Lecture
- **E** = Étirements
- **C** = Cardio
- **W** = Weightlifting
- **PB** = Protéines/Bouffe
- **CE** = Consommation eau
- **BP** = Big P
- **BW** = Big W
- **QF** = QT Friends
- **QMat** = QT Matteo
- **QFel** = QT Felix
- **QG** = QT Girlfriend
- **Sol** = Soleil matinal
- **Mar** = Marche midi

### Format 3: Colon Separator
```
"Sommeil: 1, Cardio: 1, Méditation: 0"
```

---

## Voice Examples

### Quick Morning Log
**Say:** "Run quick habit log: S 1 C 1 M 0 J 0 L 0 E 1"

**Returns:** Score instantly

### Afternoon Update
**Say:** "Run quick habit log: Sommeil 1, Cardio 1, Journal done"

**Returns:** Updated score

### Quick Before Bed
**Say:** "Run quick habit log: Sommeil 1, Meditation 1, Journal 1, Plan 1"

**Returns:** Final score + summary

---

## What Gets Saved

Each log creates/updates your daily entry with:
- ✓ All 18 essential habits tracked
- ✓ Daily score (0-100)
- ✓ Completed count
- ✓ Timestamp

Data syncs to your PKA database and habit tracker.

---

## Score Calculation

- **18 essential habits** = 100 points total
- Each habit = ~5.56 points
- 0 habits done = 0/100
- All 18 done = 100/100
- Optional habits don't count toward score

---

## Tips

1. **Log once per day.** Either morning, afternoon, or evening — pick one anchor time.

2. **Use abbreviations.** Faster to speak: "S1 C0 M1 J0" vs full names.

3. **Don't overthink it.** Quick summary is enough. If you did stretching, cardio, and meditation, that's what matters.

4. **Works offline.** The app caches your team and context, so voice commands work anywhere.

5. **Check your score.** The return shows your daily total immediately.

---

## Example Voice Command Sequence

**Morning (after habits done):**
```
"Gemini, run quick habit log: S1 C1 M1 J1 L0 E1"
```
*Returns: Score: 67/100*

**Later (if you do more):**
```
"Run quick habit log: S1 C1 M1 J1 L1 E1"
```
*Returns: Score: 83/100*

Each time you run it, it **updates** that day's entry with the new log.

---

## Troubleshooting

**Q: "Gemini can't find the script"**
A: Make sure you use the full path: `/Users/yves-erikslater/Desktop/PKA/scripts/quick_habit_log.py`

**Q: "It says 'No habits parsed'"**
A: Check the format. Examples that work:
- `"S1 C1 M0 J1"` ✓
- `"Sommeil 1, Cardio 1"` ✓
- `"sommeil 1 cardio 1"` ✓

**Q: "I want to log 15 habits but only have time for 5 input fields"**
A: Only log the ones you did. The rest default to 0 automatically.

---

## What Happens When You Log

1. Gemini executes the script
2. Script parses your input
3. Calculates your daily score
4. Saves to the PKA database
5. Returns score + summary
6. Data syncs to your tracker and briefing system

All in < 3 seconds. ⚡

---

*Created: 2026-04-26*
