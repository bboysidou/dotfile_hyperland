#!/usr/bin/env python3
import calendar
import datetime as dt
import json
import locale
from zoneinfo import ZoneInfo

locale.setlocale(locale.LC_TIME, "")

ZONES = [
    ("Montreal", "America/Montreal"),
    ("Alberta", "America/Edmonton"),
    ("San Francisco", "America/Los_Angeles"),
]

now = dt.datetime.now().astimezone()
bar = "󰥔 " + now.strftime("%a, %d. %b %H:%M")

cal = calendar.Calendar(firstweekday=calendar.MONDAY)
rows = [
    now.strftime("%B %Y"),
    " ".join(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]),
]
for week in cal.monthdatescalendar(now.year, now.month):
    cells = []
    for d in week:
        if d.month != now.month:
            cells.append("  ")
        else:
            day = f"{d.day:2d}"
            if d.day == now.day:
                cells.append(f"<span color='#75f1fa'><b>{day}</b></span>")
            else:
                cells.append(day)
    rows.append(" ".join(cells))
calendar_text = "\n".join(rows)

world_lines = []
for name, zone in ZONES:
    z = dt.datetime.now(ZoneInfo(zone))
    world_lines.append(f"{name.ljust(15)}{z.strftime('%H:%M %Z')}")
world_text = "\n".join(world_lines)

tooltip = f"<tt><small>{calendar_text}</small></tt>\n\n<b>World</b>\n<tt>{world_text}</tt>"

print(json.dumps({"text": bar, "tooltip": tooltip}))
