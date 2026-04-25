#!/usr/bin/env python3
"""Generate a 30-day habit score report and open it in the browser."""

import sqlite3
import webbrowser
from datetime import date, timedelta

DB     = "/Users/yves-erikslater/Desktop/PKA/Database/pka.db"
REPORT = "/Users/yves-erikslater/Desktop/PKA/Database/habits_report.html"
DAYS   = 30


def main():
    today     = date.today()
    start     = today - timedelta(days=DAYS - 1)
    date_list = [start + timedelta(days=i) for i in range(DAYS)]
    date_strs = [d.isoformat() for d in date_list]

    conn   = sqlite3.connect(DB)
    habits = conn.execute(
        "SELECT id, name, score FROM habits WHERE active=1 ORDER BY score DESC, display_order"
    ).fetchall()
    logs   = conn.execute(
        "SELECT habit_id, log_date, done FROM habit_logs WHERE log_date >= ? AND log_date <= ?",
        (date_strs[0], date_strs[-1])
    ).fetchall()
    conn.close()

    log_map = {}
    for hid, d, done in logs:
        log_map.setdefault(hid, {})[d] = done

    max_score = sum(h[2] for h in habits)

    habit_data = []
    for hid, name, score in habits:
        daily      = [log_map.get(hid, {}).get(d, 0) for d in date_strs]
        days_done  = sum(daily)
        rate       = round(days_done / DAYS * 100)
        habit_data.append({"name": name, "score": score, "rate": rate, "daily": daily})

    # Daily score totals
    daily_scores = []
    for i in range(DAYS):
        earned = sum(h["score"] * h["daily"][i] for h in habit_data)
        daily_scores.append(earned)

    today_score = daily_scores[-1]
    week_avg    = round(sum(daily_scores[-7:]) / 7)
    month_avg   = round(sum(daily_scores) / DAYS)
    best_day    = max(daily_scores)

    # Build date headers
    dow_map = ["L", "M", "M", "J", "V", "S", "D"]
    date_headers = ""
    for d in date_list:
        cls = ' class="today"' if d == today else ""
        date_headers += f'<th{cls}><small>{dow_map[d.weekday()]}</small><br>{d.day}</th>'

    # Build habit rows — sorted by score descending (highest impact first)
    rows = ""
    for h in habit_data:
        rate = h["rate"]
        rc   = "g" if rate >= 70 else ("o" if rate >= 40 else "r")
        cells = "".join(
            f'<td class="c {"d" if v else "m"}"></td>' for v in h["daily"]
        )
        rows += (
            f'<tr>'
            f'<td class="hn">'
            f'  <span class="badge">{h["score"]}</span>'
            f'  {h["name"]}'
            f'</td>'
            f'{cells}'
            f'<td class="rt {rc}">{rate}%</td>'
            f'<td class="rb"><div class="rbg"><div class="rbf {rc}" style="width:{rate}%"></div></div></td>'
            f'</tr>'
        )

    # Daily score sparkline data for the mini bar chart
    bar_max   = max_score or 1
    score_bars = ""
    for i, s in enumerate(daily_scores):
        pct    = round(s / bar_max * 100)
        is_today = (i == DAYS - 1)
        cls    = "sb-today" if is_today else "sb"
        score_bars += f'<div class="{cls}" style="height:{pct}%" title="{s} pts"></div>'

    html = f"""<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Habits — {today}</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#f5f5f7;padding:32px 28px;color:#1d1d1f}}
h1{{font-size:22px;font-weight:700;margin-bottom:4px}}
.sub{{color:#86868b;font-size:13px;margin-bottom:24px}}

.stats{{display:flex;gap:14px;margin-bottom:20px;flex-wrap:wrap}}
.stat{{background:#fff;border-radius:12px;padding:14px 20px;box-shadow:0 1px 3px rgba(0,0,0,.07)}}
.sv{{font-size:26px;font-weight:700;line-height:1.1}}
.sl{{font-size:10px;color:#86868b;text-transform:uppercase;letter-spacing:.07em;margin-top:4px}}
.sv.hi{{color:#30d158}}

.spark{{background:#fff;border-radius:12px;padding:16px 20px;box-shadow:0 1px 3px rgba(0,0,0,.07);margin-bottom:24px}}
.spark-label{{font-size:11px;color:#86868b;margin-bottom:10px}}
.spark-bars{{display:flex;align-items:flex-end;gap:2px;height:48px}}
.sb{{flex:1;background:#d1d1d6;border-radius:2px 2px 0 0;min-height:2px}}
.sb-today{{flex:1;background:#30d158;border-radius:2px 2px 0 0;min-height:2px}}

.wrap{{overflow-x:auto;-webkit-overflow-scrolling:touch}}
table{{border-collapse:separate;border-spacing:1px;background:#dcdce0;border-radius:12px;overflow:hidden;width:100%}}
thead tr th{{background:#f5f5f7;font-size:10px;color:#86868b;font-weight:500;padding:6px 2px;text-align:center;min-width:22px}}
thead tr th.today{{background:#fff;color:#1d1d1f;font-weight:700}}
td{{background:#fff}}
.hn{{font-size:13px;padding:7px 14px 7px 12px;white-space:nowrap;min-width:190px}}
.badge{{display:inline-block;background:#f0f0f2;color:#555;font-size:10px;font-weight:700;border-radius:4px;padding:1px 5px;margin-right:6px;min-width:20px;text-align:center}}
.c{{width:22px;height:34px;padding:0}}
.d{{background:#30d158}}
.m{{background:#f0f0f2}}
.rt{{font-size:12px;font-weight:600;padding:0 10px;white-space:nowrap;text-align:right}}
.g{{color:#30d158}}.o{{color:#ff9f0a}}.r{{color:#ff453a}}
.rb{{padding:0 16px 0 6px;min-width:90px}}
.rbg{{background:#e5e5ea;border-radius:4px;height:6px}}
.rbf{{height:6px;border-radius:4px}}
.rbf.g{{background:#30d158}}.rbf.o{{background:#ff9f0a}}.rbf.r{{background:#ff453a}}
tbody tr:hover td{{background:#fafafa}}
</style>
</head>
<body>
<h1>Habits</h1>
<p class="sub">Last {DAYS} days · {today.strftime("%B %d, %Y")} · Max {max_score} pts/day</p>

<div class="stats">
  <div class="stat">
    <div class="sv hi">{today_score}<span style="font-size:14px;color:#86868b"> / {max_score}</span></div>
    <div class="sl">Score Today</div>
  </div>
  <div class="stat">
    <div class="sv">{week_avg}<span style="font-size:14px;color:#86868b"> / {max_score}</span></div>
    <div class="sl">7-Day Average</div>
  </div>
  <div class="stat">
    <div class="sv">{month_avg}<span style="font-size:14px;color:#86868b"> / {max_score}</span></div>
    <div class="sl">30-Day Average</div>
  </div>
  <div class="stat">
    <div class="sv">{best_day}<span style="font-size:14px;color:#86868b"> / {max_score}</span></div>
    <div class="sl">Best Day</div>
  </div>
</div>

<div class="spark">
  <div class="spark-label">Daily score — last 30 days</div>
  <div class="spark-bars">{score_bars}</div>
</div>

<div class="wrap">
<table>
  <thead>
    <tr>
      <th style="text-align:left;padding-left:12px">Habit</th>
      {date_headers}
      <th colspan="2" style="text-align:left;padding-left:10px">Freq</th>
    </tr>
  </thead>
  <tbody>{rows}</tbody>
</table>
</div>
</body>
</html>"""

    with open(REPORT, "w") as f:
        f.write(html)

    webbrowser.open(f"file://{REPORT}")
    print(f"Report opened — {REPORT}")


if __name__ == "__main__":
    main()
