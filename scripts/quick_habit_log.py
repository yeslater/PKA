#!/usr/bin/env python3
"""
Quick Habit Logger — log habits in seconds via voice or text.

Usage examples:
  python3 quick_habit_log.py "sommeil 1, cardio 1, meditation 0, lecture 1"
  python3 quick_habit_log.py "S1 C1 M0 J1 P0 E1 WL0 QL1 QM1"
  python3 quick_habit_log.py "all good today except stretching"

Returns: Daily score, progress, and quick summary.
"""

import sqlite3
import sys
import re
from datetime import datetime
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "Database" / "pka.db"

HABITS = {
    'Sommeil': 'sommeil',
    'Méditation': 'meditation',
    'Plan': 'plan',
    'Journal': 'journal',
    'Lecture': 'lecture',
    'Étirements': 'etirements',
    'Cardio': 'cardio',
    'Weightlifting': 'weightlifting',
    'Protéines/Bouffe': 'proteines',
    'Consommation eau': 'consommation_eau',
    'Big P': 'big_p',
    'Big W': 'big_w',
    'QT Friends': 'qt_friends',
    'QT Matteo': 'qt_matteo',
    'QT Felix': 'qt_felix',
    'QT Girlfriend': 'qt_girlfriend',
    'Soleil matinal': 'soleil_matinal',
    'Marche midi': 'marche_midi',
}

HABIT_ABBREV = {
    'S': 'Sommeil',
    'M': 'Méditation',
    'P': 'Plan',
    'J': 'Journal',
    'L': 'Lecture',
    'E': 'Étirements',
    'C': 'Cardio',
    'W': 'Weightlifting',
    'PB': 'Protéines/Bouffe',
    'CE': 'Consommation eau',
    'BP': 'Big P',
    'BW': 'Big W',
    'QF': 'QT Friends',
    'QMat': 'QT Matteo',
    'QFel': 'QT Felix',
    'QG': 'QT Girlfriend',
    'Sol': 'Soleil matinal',
    'Mar': 'Marche midi',
}

def parse_input(user_input):
    """Parse various input formats and return habit dict."""
    habits_dict = {h: 0 for h in HABITS}

    # Try comma-separated format: "Sommeil 1, Cardio 0, Méditation 1"
    if ',' in user_input or ':' in user_input:
        parts = re.split('[,;]', user_input)
        for part in parts:
            part = part.strip()
            # Match "Habit 1" or "Habit: 1" format
            match = re.match(r'([a-zàâäœé\s/]+)\s*:?\s*([01])', part, re.IGNORECASE)
            if match:
                habit_name = match.group(1).strip()
                value = int(match.group(2))
                # Find matching habit
                for full_name in HABITS:
                    if habit_name.lower() in full_name.lower():
                        habits_dict[full_name] = value
                        break

    # Try abbreviated format: "S1 C1 M0 J1"
    else:
        tokens = user_input.split()
        for token in tokens:
            match = re.match(r'([a-z]+)([01])', token, re.IGNORECASE)
            if match:
                abbrev = match.group(1).upper()
                value = int(match.group(2))
                if abbrev in HABIT_ABBREV:
                    full_name = HABIT_ABBREV[abbrev]
                    habits_dict[full_name] = value

    return habits_dict

def calculate_score(habits_dict):
    """Calculate daily score (18 essential habits = 100 points)."""
    essential = [
        'Sommeil', 'Méditation', 'Plan', 'Journal', 'Lecture',
        'Étirements', 'Cardio', 'Weightlifting', 'Protéines/Bouffe',
        'Consommation eau', 'Big P', 'Big W', 'QT Friends', 'QT Matteo',
        'QT Felix', 'QT Girlfriend', 'Soleil matinal', 'Marche midi'
    ]

    completed = sum(habits_dict.get(h, 0) for h in essential)
    score = (completed / len(essential)) * 100
    return int(score), completed, len(essential)

def log_habit(user_input):
    """Parse input and log habit for today."""
    habits_dict = parse_input(user_input)

    if sum(habits_dict.values()) == 0:
        print("❌ No habits parsed. Try: 'Sommeil 1, Cardio 1, Méditation 0'")
        return

    # Save to database
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    date_str = datetime.now().strftime('%Y-%m-%d')
    values = [date_str]

    for habit in HABITS:
        values.append(habits_dict.get(habit, 0))

    score, completed, total = calculate_score(habits_dict)
    values.append(score)

    try:
        c.execute(f'''
            INSERT OR REPLACE INTO habits_daily (
                date, sommeil, meditation, plan, journal, lecture,
                etirements, cardio, weightlifting, proteines, consommation_eau,
                big_p, big_w, qt_friends, qt_matteo, qt_felix, qt_girlfriend,
                soleil_matinal, marche_midi, completed_count
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', values)
        conn.commit()

        # Print summary
        print(f"\n✓ Today logged: {completed}/{total} essential habits")
        print(f"📊 Daily Score: {score}/100")

        # Show completed habits
        completed_list = [h for h, v in habits_dict.items() if v == 1 and h in [
            'Sommeil', 'Méditation', 'Plan', 'Journal', 'Lecture',
            'Étirements', 'Cardio', 'Weightlifting', 'Protéines/Bouffe',
            'Consommation eau', 'Big P', 'Big W', 'QT Friends', 'QT Matteo',
            'QT Felix', 'QT Girlfriend', 'Soleil matinal', 'Marche midi'
        ]]

        if completed_list:
            print(f"✓ Completed: {', '.join(completed_list[:3])}")
            if len(completed_list) > 3:
                print(f"             {', '.join(completed_list[3:])}")

        print()
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        conn.close()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Quick Habit Logger")
        print("==================")
        print("Usage: python3 quick_habit_log.py \"habit input\"")
        print()
        print("Examples:")
        print('  "Sommeil 1, Cardio 1, Méditation 0, Lecture 1"')
        print('  "S1 C1 M0 J1 P0 E1 W0"')
        print('  "All done today except meditation"')
        print()
        print("Abbreviations: S(ommeil) M(éditation) P(lan) J(ournal) L(ecture)")
        print("               E(tirements) C(ardio) W(eightlifting) PB(roteines)")
        print("               QF(riends) QMat(teo) QFel(ix) QG(irlfriend)")
        sys.exit(1)

    user_input = ' '.join(sys.argv[1:])
    log_habit(user_input)
