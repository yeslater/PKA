#!/usr/bin/env python3
"""Daily habit check-in — type a number to toggle, q to quit."""

import sqlite3
import os
from datetime import date

DB = "/Users/yves-erikslater/Desktop/PKA/Database/pka.db"


def main():
    today = date.today().isoformat()

    try:
        conn = sqlite3.connect(DB)
    except sqlite3.Error as e:
        print(f"\n  Error opening database: {e}")
        print(f"  Make sure you've run pka_setup.sql and habits_extension.sql first.\n")
        return

    habits = conn.execute(
        "SELECT id, name, score FROM habits WHERE active=1 ORDER BY display_order, name"
    ).fetchall()

    if not habits:
        print("\n  No habits found. Add them to the habits table first.\n")
        conn.close()
        return

    max_score = sum(h[2] for h in habits)

    conn.executemany(
        "INSERT OR IGNORE INTO habit_logs (habit_id, log_date, done) VALUES (?,?,0)",
        [(h[0], today) for h in habits]
    )
    conn.commit()

    while True:
        state = {
            r[0]: r[1] for r in conn.execute(
                "SELECT habit_id, done FROM habit_logs WHERE log_date=?", (today,)
            ).fetchall()
        }
        score = sum(h[2] for h in habits if state.get(h[0]))

        os.system("clear")
        print(f"\n  Habits · {today}   Score: {score} / {max_score}\n")
        for i, (hid, name, pts) in enumerate(habits, 1):
            mark = "✓" if state.get(hid) else "·"
            print(f"    {i:>2}.  [{mark}]  {name:<16}  +{pts}")
        print("\n  Enter number to toggle · q to quit\n")

        cmd = input("  > ").strip().lower()

        if cmd == "q":
            break

        tokens = cmd.replace(",", " ").split()
        for token in tokens:
            try:
                idx = int(token) - 1
                if 0 <= idx < len(habits):
                    hid = habits[idx][0]
                    current = state.get(hid, 0)
                    conn.execute(
                        "UPDATE habit_logs SET done=? WHERE habit_id=? AND log_date=?",
                        (1 - current, hid, today)
                    )
            except ValueError:
                pass
        conn.commit()

    final_state = {
        r[0]: r[1] for r in conn.execute(
            "SELECT habit_id, done FROM habit_logs WHERE log_date=?", (today,)
        ).fetchall()
    }
    conn.close()
    final_score = sum(h[2] for h in habits if final_state.get(h[0]))
    print(f"\n  Saved — {final_score} / {max_score} pts today.\n")


if __name__ == "__main__":
    main()
