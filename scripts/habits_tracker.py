#!/usr/bin/env python3
"""
Daily Habits Tracker — Backend for logging and analyzing habit data.
Reads/writes from PKA.db (SQLite). Run alongside the HTML tracker.

Usage:
    python3 scripts/habits_tracker.py --save "2026-04-25" "Sommeil:1,Méditation:0,..."
    python3 scripts/habits_tracker.py --weekly
    python3 scripts/habits_tracker.py --summary
"""

import sqlite3
import json
import sys
from datetime import datetime, timedelta
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "Database" / "pka.db"

ESSENTIAL_HABITS = [
    'Sommeil',
    'Méditation',
    'Plan',
    'Journal',
    'Lecture',
    'Étirements',
    'Cardio',
    'Weightlifting',
    'Protéines/Bouffe',
    'Consommation eau',
    'Big P',
    'Big W',
    'QT Friends',
    'QT Matteo',
    'QT Felix',
    'QT Girlfriend'
]

OPTIONAL_HABITS = [
    'Nouvelle recette',
    'Pratique guitare ou piano',
    'Rangement-menage'
]

HABITS = ESSENTIAL_HABITS + OPTIONAL_HABITS

def init_db():
    """Create habits table if it doesn't exist."""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    # Create table
    c.execute('''
        CREATE TABLE IF NOT EXISTS habits_daily (
            date TEXT PRIMARY KEY,
            sommeil INTEGER,
            meditation INTEGER,
            plan INTEGER,
            journal INTEGER,
            lecture INTEGER,
            etirements INTEGER,
            cardio INTEGER,
            weightlifting INTEGER,
            proteines INTEGER,
            consommation_eau INTEGER,
            big_p INTEGER,
            big_w INTEGER,
            qt_friends INTEGER,
            qt_matteo INTEGER,
            qt_felix INTEGER,
            qt_girlfriend INTEGER,
            nouvelle_recette INTEGER,
            pratique_musique INTEGER,
            rangement_menage INTEGER,
            completed_count INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    conn.commit()
    conn.close()

def save_habits(date_str, habits_dict):
    """Save a day's habits to the database."""
    init_db()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    # Map habit names to column names
    column_map = {
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
        'Nouvelle recette': 'nouvelle_recette',
        'Pratique guitare ou piano': 'pratique_musique',
        'Rangement-menage': 'rangement_menage'
    }

    values = [date_str]
    completed = 0

    for habit in HABITS:
        val = habits_dict.get(habit, 0)
        values.append(val)
        completed += val

    values.append(completed)

    try:
        c.execute(f'''
            INSERT OR REPLACE INTO habits_daily (
                date, sommeil, meditation, plan, journal, lecture,
                etirements, cardio, weightlifting, proteines, consommation_eau,
                big_p, big_w, qt_friends, qt_matteo, qt_felix, qt_girlfriend,
                nouvelle_recette, pratique_musique, rangement_menage, completed_count
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', values)
        conn.commit()
        print(f"✓ Saved {date_str}: {completed}/15 habits completed")
    except Exception as e:
        print(f"✗ Error saving: {e}")
    finally:
        conn.close()

def weekly_summary():
    """Show last 7 days of data with success rates."""
    init_db()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    # Get last 7 days
    today = datetime.now()
    week_ago = today - timedelta(days=7)

    c.execute('''
        SELECT date, sommeil, meditation, plan, journal, lecture,
               etirements, cardio, weightlifting, proteines, consommation_eau,
               big_p, big_w, qt_friends, qt_matteo, qt_felix, qt_girlfriend,
               nouvelle_recette, pratique_musique, rangement_menage, completed_count
        FROM habits_daily
        WHERE date >= ?
        ORDER BY date DESC
    ''', (week_ago.strftime('%Y-%m-%d'),))

    rows = c.fetchall()
    conn.close()

    if not rows:
        print("No habit data yet. Start tracking to see results.")
        return

    print("\n" + "="*70)
    print("WEEKLY HABIT SUMMARY (Last 7 Days)")
    print("★ = Essential | (opt) = Optional")
    print("="*70)

    # Calculate success rates
    habit_totals = {h: 0 for h in HABITS}
    total_days = len(rows)

    for row in rows:
        date = row[0]
        completed = row[-2]
        print(f"\n{date}: {completed}/19 ✓")

        for i, habit in enumerate(HABITS):
            if row[i+1] == 1:
                habit_totals[habit] += 1

    print("\n" + "-"*70)
    print("SUCCESS RATES:")
    print("-"*70)

    # Sort by success rate
    sorted_habits = sorted(habit_totals.items(),
                          key=lambda x: x[1], reverse=True)

    for habit, count in sorted_habits:
        rate = (count / total_days) * 100
        bar = "█" * count + "░" * (total_days - count)
        print(f"{habit:20} {bar} {count}/{total_days} ({rate:.0f}%)")

    print("\n" + "="*70)

def summary():
    """Show all-time stats."""
    init_db()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    c.execute('SELECT COUNT(*) FROM habits_daily')
    total_days = c.fetchone()[0]

    if total_days == 0:
        print("No habit data yet.")
        conn.close()
        return

    print("\n" + "="*70)
    print(f"ALL-TIME STATS ({total_days} days tracked)")
    print("="*70)

    c.execute(f'''
        SELECT
            ROUND(AVG(completed_count), 1) as avg_daily,
            MAX(completed_count) as best_day,
            MIN(completed_count) as worst_day
        FROM habits_daily
    ''')

    avg, best, worst = c.fetchone()
    print(f"\nAverage per day: {avg}/19")
    print(f"Best day: {best}/19")
    print(f"Worst day: {worst}/19")

    c.execute(f'''
        SELECT SUM(sommeil), SUM(meditation), SUM(plan), SUM(journal), SUM(lecture),
               SUM(etirements), SUM(cardio), SUM(weightlifting), SUM(proteines),
               SUM(consommation_eau), SUM(big_p), SUM(big_w), SUM(qt_friends),
               SUM(qt_matteo), SUM(qt_felix), SUM(qt_girlfriend),
               SUM(nouvelle_recette), SUM(pratique_musique), SUM(rangement_menage)
        FROM habits_daily
    ''')

    totals = c.fetchone()
    conn.close()

    print("\nESSENTIAL HABITS:")
    for habit in ESSENTIAL_HABITS:
        idx = HABITS.index(habit)
        count = totals[idx]
        rate = (count / total_days) * 100
        print(f"  ★ {habit:25} {count:3}/{total_days} ({rate:5.1f}%)")

    print("\nOPTIONAL HABITS:")
    for habit in OPTIONAL_HABITS:
        idx = HABITS.index(habit)
        count = totals[idx]
        rate = (count / total_days) * 100
        print(f"    {habit:25} {count:3}/{total_days} ({rate:5.1f}%)")

    print("="*70 + "\n")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: habits_tracker.py --weekly | --summary")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == '--weekly':
        weekly_summary()
    elif cmd == '--summary':
        summary()
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
