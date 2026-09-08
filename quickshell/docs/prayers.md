# Prayer times — the Prayers tab, the bar pill and the alerts

Added 2026-09-08. Spec: `docs/superpowers/specs/2026-09-08-prayer-times-design.md`.
Plan: `docs/superpowers/plans/2026-09-08-prayer-times.md`.

Five prayers plus Shurūq in the dashboard's **Prayers** tab, a pill in the centre
bar next to the clock, and critical notifications 20 / 10 / 5 minutes before each
prayer and at the prayer time itself.

---

## Three layers

| Layer | File | Owns |
| --- | --- | --- |
| Astronomy | `core/helpers/Solar.qml` | Pure functions. No state, no I/O. The only thing that computes a time. |
| Conventions | `core/constants/Prayers.qml` | Method angles, Asr factors, high-latitude rules, endpoints, the Tiaret fallback. |
| Geography | `services/Geo.qml` | The only file that reaches the network. Owns no persistence, which is what keeps it acyclic with `Prayer`. |
| State | `services/Prayer.qml` | `prayer.json`, the settings, and a three-day window of times. |
| Alerts | `services/PrayerAlerts.qml` | The only file that emits notifications. |
| Host | `modules/prayers/PrayerCenter.qml` | Instantiates the alerts and exposes `qs ipc call prayers`. |

Times are computed locally. The network is touched in exactly two places, and
never on the path that produces a time: IP detection once at startup, and city
search when you type into the pin field.

---

## Why a three-day window

`Prayer.schedule` computes yesterday, today and tomorrow, not just today.
Yesterday is needed because at 01:00 the interval you are inside began at
yesterday's Isha; tomorrow is needed because after Isha the next prayer is
tomorrow's Fajr. Computing only today gives a null `current` after midnight and a
null `next` after Isha.

---

## Elevation is deliberately never applied

`Solar.riseSetAngle` takes an elevation, and `Prayer.compute` always passes `0`.

This is not an oversight. Tiaret sits at about 1080 m, and feeding that in moves
sunrise 6 minutes earlier and Maghrib 7 minutes later than the published
timetable:

```
elevation 1080 → Maghrib 18:12      elevation 0 → Maghrib 18:05     (15-01-2026)
```

AlAdhan and effectively every mainstream timetable compute at sea level. A
Maghrib seven minutes later than the local mosque's is the wrong iftar time in
Ramadan. The `elevation` the geocoder returns is stored and ignored.

---

## Timezone: detect the mismatch, never silently correct it

Times use the **system's** UTC offset, taken as
`-new Date(y, m, d, 12).getTimezoneOffset() / 60` — at local noon of the target
date, which makes it DST-correct without a date library and without depending on
`Intl` support in Qt's V4 engine.

The place's `tz` name is used for one thing only: detecting that it disagrees
with the system clock, via `Geo.offsetFor`. On a mismatch the location card says
so in red.

If the IP puts you in Edmonton while the laptop is still on `Africa/Algiers`,
then every clock on the machine is wrong, not just this panel. Silently rendering
Edmonton times against an Algiers clock produces numbers that look entirely
plausible and are hours off, so the panel refuses to hide it.

**`Geo.offsetFor` returns `real`, not `int`, and this matters.** It returns `NaN`
until the zone has been resolved. Typing it `int` coerces that `NaN` to `0`,
which then compares unequal to a real offset and reports a permanent false
mismatch. The same trap applies to `Prayer.placeZoneOffset`.

Zones are resolved from `Component.onCompleted` as well as `onPlaceChanged`,
because a property binding's *initial* value fires no change signal — the zone
would otherwise never be requested at all.

---

## High latitude

At Edmonton's 53.5°N the sun never reaches 18° below the horizon between roughly
mid-May and late July, so Fajr and Isha have no astronomical solution.
`Solar.sunAngleTime` returns `NaN` there — deliberately not clamped — and
`adjustHighLats` supplies the times from a night split. The default rule is
angle-based; `midnight`, `seventh` and `none` are selectable in the panel.
With `none`, `NaN` reaches the UI and renders as `—`.

Tiaret at 35°N never triggers any of this. It starts mattering on landing in
Alberta.

---

## Verifying the arithmetic

`check_prayer.qml` at the repo root is the regression gate.

```bash
timeout 20 qs -p check_prayer.qml 2>&1 | grep PRAYER-CHECK
```

Expected: `PRAYER-CHECK PASS worst=1min cases=6 failures=0`

The six reference rows were measured against AlAdhan (method 3 = MWL, school 0),
tolerance ±1 minute:

| Case | Fajr | Sunrise | Dhuhr | Asr | Maghrib | Isha |
| --- | --- | --- | --- | --- | --- | --- |
| Tiaret 15-01-2026 | 06:34 | 08:03 | 13:04 | 15:45 | 18:05 | 19:30 |
| Tiaret 21-03-2026 | 05:32 | 06:57 | 13:02 | 16:28 | 19:07 | 20:27 |
| Tiaret 15-06-2026 | 03:51 | 05:39 | 12:55 | 16:44 | 20:11 | 21:52 |
| Tiaret 08-09-2026 | 05:05 | 06:32 | 12:52 | 16:28 | 19:12 | 20:34 |
| Tiaret 21-12-2026 | 06:28 | 08:00 | 12:53 | 15:28 | 17:46 | 19:12 |
| Edmonton 15-06-2026 | 02:58 | 05:04 | 13:35 | 18:01 | 22:05 | 00:04 |

The Edmonton row is the high-latitude test. Its Isha lands at **00:04** — a raw
fractional hour of 24.07, on the following calendar day. Any implementation that
assumes prayer times stay inside one calendar day fails that row.

**Do not widen the tolerance or edit the expected table to make a change pass.**
Those are measured reference values.

---

## Alerts

`PrayerAlerts` hangs off `Time.now`, which is already a `SystemClock` at
`Minutes` precision — no new timer exists. Each tick it looks for an **exact
minute match** against `prayerTime − 20 / − 10 / − 5 / − 0` for the five prayers.
Shurūq never alerts.

Exact matching is deliberate: resuming a suspended laptop at 15:00 must not dump
four hours of stale prayer warnings on you. A missed alert is not information any
more, it is noise.

All four fire at `-u critical`. `Appearance.notif.timeoutCritical` is `0` and
`services/Notif.qml` `arm()` returns early when `timeout <= 0`, so they stay on
screen until dismissed.

### `replaces_id` is not honoured — measured 2026-09-08

Sending two `notify-send -r 9200` alerts two seconds apart produced **two**
toasts, not one replaced in place. Quickshell's `NotificationServer` ignores the
freedesktop replace id.

Left alone that is five prayers × four alerts = twenty sticky toasts a day.
`PrayerAlerts.supersede()` fixes it from inside the shell instead: before
enqueueing an alert it walks `Notifs.toArray()` and dismisses any tracked
notification whose `appName` is ours and whose summary starts with that prayer's
label. Verified: firing "Asr in 20 minutes" then "Asr in 10 minutes" leaves
exactly one toast.

The `-r` flag is still sent. It is the standards-correct thing to send and costs
nothing if the server ever starts honouring it.

### Duplicates

`fired` is in-memory and keyed `yyyy-MM-dd|prayer|offset`. A shell restart loses
it, so a restart *within the same minute as an alert* can repeat that alert once.
Persisting it would mean a disk write per alert to prevent a rare duplicate of a
notification you wanted anyway.

---

## Location

Detection uses **`ipwho.is`**, not `ipapi.co`. As of 2026-09-08 `ipapi.co`
returns HTTP 403 behind a Cloudflare challenge for this client. `ipwho.is` is
keyless and returns `latitude`, `longitude`, `city`, `country_code` and
`timezone.id`.

Detection runs **once**, from `Component.onCompleted`, plus on demand via *Detect
again*. Do not put it on a repeating timer — that is how a free endpoint starts
refusing.

IP geolocation resolves to your ISP's egress, not to you. Detection here lands on
Bordj Menaiel, about 250 km from Tiaret, which shifts every time by roughly ten
minutes. **That is what the pin is for**: type a city, pick a result, and the
resolved coordinates are stored in `prayer.json` forever. City search uses
Open-Meteo's keyless geocoder. Once pinned, nothing reaches the network again.

Resolution order is `pinned ?? Geo.detected ?? cached ?? Tiaret`. The final
fallback is Tiaret, not Greenwich, so a cold boot with no network and an empty
state file still shows correct times.

State lives at `$XDG_STATE_HOME/quickshell/prayer.json`.

---

## The bar pill

`modules/bar/components/PrayerPill.qml` sits in `entriesCentre` beside the clock,
separated by a one-pixel rule that the pill draws as its own first child —
`BarSlot` renders one delegate per entry and has nowhere to put a between-items
divider without special-casing indices.

**The pill's `HoverHandler` writes `DashState.barHover`, and that is required,
not decorative.** `WorldClock` was previously the only source of that property;
without this, moving the cursor from the clock onto the pill reports "not
hovering" and closes the dashboard mid-reach. See
`dashboard.md § Two hover sources, one state`.

The pill turns `Colours.critical` inside the last 20 minutes.
`Appearance.prayer.urgentWindow` and `alertOffsets[0]` are both 20 by
construction, so the pill changes colour at exactly the moment the first
notification fires.

---

## Gotchas found while building this

- **Quickshell singletons survive a config reload.** Editing `Icons.qml` or any
  other singleton and letting `settings.watchFiles` reload does **not** pick up
  the new values — the log says "Configuration Loaded" while the old values are
  still live. A full `qs kill` + relaunch is required.
- **A newly created module directory needs a restart too.** Adding
  `modules/prayers/` produced `module "qs.modules.prayers" is not installed` on
  reload; a fresh process resolved it immediately.
- **`Qt.exit()` and `Quickshell.quit()` do not exist / do not work here.** A
  headless check must run under `timeout` and be judged by grepping stdout. Its
  exit code is always 124.
- **Nerd Font codepoints are not Material Design codepoints.** Guessing gives
  tofu or, worse, the wrong icon that still renders. `mosque` is `U+F1827` here,
  not the MDI `U+F1613`. Read the font's `post` table glyph names:

```bash
python3 - <<'EOF'
import struct
data = open("/home/sidouxp3/.fonts/JetBrainsMonoNerdFont-Regular.ttf", "rb").read()
# parse post + cmap, then grep names for "mosque", "map-marker", ...
EOF
```

  The full name-to-codepoint dump used for this feature is in the session that
  added it; the practical rule is: never hand-write a glyph, look it up.
