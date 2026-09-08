# Prayer times — design

**Date:** 2026-09-08
**Status:** approved for planning
**Scope:** a `Prayers` tab in the dashboard drawer, a centre-bar pill, and
critical desktop notifications at 20 / 10 / 5 minutes before each prayer and at
the prayer time itself.

---

## Decisions taken (and by whom)

| Decision | Choice | Source |
| --- | --- | --- |
| Times source | Computed locally in QML. No runtime network for times. | user |
| Location source | Auto-detected from IP, with a manual pin that overrides it. | user |
| Calculation method default | MWL / Algeria — Fajr 18°, Isha 17°. Switchable in-panel. | user is Algerian; both conventions agree at 18/17 |
| Asr | Standard shadow factor 1 (Maliki, agrees with Shafi'i). Switchable to Hanafi (2). | user confirmed Maliki |
| High-latitude rule | Angle-based night split. Switchable. | recommended, user did not object |
| Alerts | 20 / 10 / 5 minutes before **and** at the time. | user |
| Alert urgency | `critical` for all four. | user ("urgent so I can see it") |
| Sound | None. Visual only. | user |
| Scope | Panel + settings + **bar pill**. | user |
| Pill placement | Centre slot, beside the clock, pipe separator. | user |
| Prayer naming | Transliterated only — Fajr, Shurūq, Dhuhr, Asr, Maghrib, Isha. | user |
| Home location | Tiaret, Algeria — 35.3711 N, 1.3170 E, `Africa/Algiers`. | user |

Sunrise (Shurūq) is displayed as an interval marker but **never alerts** — it
ends Fajr's window, it is not a prayer.

---

## 1. Why the astronomy is local and the geography is not

Prayer times are a deterministic function of latitude, longitude, date and a
handful of convention angles. Nothing about that needs a server, and depending
on one means the panel is wrong precisely when the network is down at 04:00.
So the computation is a pure function in QML.

Geography is the opposite: *where you are* genuinely is external knowledge. So
the network is touched in exactly two places, both user-initiated or
once-per-boot, and never on the path that produces a time:

1. IP detection at startup (and on demand via *Detect again*).
2. City search, when the user types a place into the pin field.

Both write their result to disk. After that the shell is fully offline.

---

## 2. Architecture

### Layer 1 — pure computation, no I/O

**`core/helpers/Solar.qml`** — singleton of pure functions. No properties, no
state, no imports beyond `Quickshell`. Everything here is directly testable from
a probe.

```
julianDay(year, month, day) -> real
sunPosition(jd) -> { declination: real, equation: real }   // degrees, hours
midDay(jd, t) -> real                                       // hours
sunAngleTime(jd, lat, angle, t, ccw) -> real                // hours, NaN if no solution
asrTime(jd, lat, factor, t) -> real                         // hours
riseSetAngle(elevation) -> real                             // degrees
```

Trig helpers work in degrees (`dsin`, `dcos`, `dtan`, `darcsin`, `darccos`,
`darctan2`, `darccot`) plus `fixAngle`, `fixHour`, `timeDiff`.

**Formulae** (standard PrayTimes formulation):

```
D   = jd - 2451545.0
g   = fixAngle(357.529 + 0.98560028 * D)          // mean anomaly
q   = fixAngle(280.459 + 0.98564736 * D)          // mean longitude
L   = fixAngle(q + 1.915 * dsin(g) + 0.020 * dsin(2g))
e   = 23.439 - 0.00000036 * D                     // obliquity
RA  = fixHour(darctan2(dcos(e) * dsin(L), dcos(L)) / 15)
eqt = fixHour(q / 15 - RA, -12)                   // equation of time, hours
decl= darcsin(dsin(e) * dsin(L))                  // declination

midDay(t)                = fixHour(12 - eqt(jd + t))
sunAngleTime(angle,t,ccw)= midDay(t) -/+ darccos(
                             (-dsin(angle) - dsin(decl) * dsin(lat))
                             / (dcos(decl) * dcos(lat))
                           ) / 15
asrTime(factor,t)        = sunAngleTime(-darccot(factor + dtan(|lat - decl|)), t, cw)
riseSetAngle(elev)       = 0.833 + 0.0347 * sqrt(max(elev, 0))
```

`darccos` of an argument outside `[-1, 1]` returns `NaN`. It must **not** be
clamped — `NaN` is the signal that the sun never reaches that depression angle,
which is what the high-latitude rule exists to handle.

**`core/constants/Prayers.qml`** — the convention tables.

```qml
readonly property var methods: [
    { id: "mwl",     label: "Muslim World League",  fajr: 18,   isha: 17 },
    { id: "algeria", label: "Algeria (Ministry)",   fajr: 18,   isha: 17 },
    { id: "isna",    label: "ISNA (N. America)",    fajr: 15,   isha: 15 },
    { id: "egypt",   label: "Egyptian Authority",   fajr: 19.5, isha: 17.5 },
    { id: "makkah",  label: "Umm al-Qura",          fajr: 18.5, ishaMinutes: 90 },
    { id: "karachi", label: "Karachi",              fajr: 18,   isha: 18 }
]
readonly property var asrSchools: [
    { id: "standard", label: "Standard (Maliki / Shafi'i)", factor: 1 },
    { id: "hanafi",   label: "Hanafi",                      factor: 2 }
]
readonly property var highLatRules: [
    { id: "angle",     label: "Angle based" },
    { id: "midnight",  label: "Middle of the night" },
    { id: "seventh",   label: "One seventh of the night" },
    { id: "none",      label: "None (leave blank)" }
]
readonly property var fallbackPlace: ({
    lat: 35.3711, lon: 1.3170, elevation: 0,
    city: "Tiaret", country: "DZ", tz: "Africa/Algiers"
})
readonly property real defaultIshaAngle: 18   // night portion when isha is minutes-based
```

`algeria` duplicating `mwl`'s angles is intentional. The numbers are the same;
the label is what tells the user which authority they are following.

**`core/enums/PrayerName.qml`** — flat singleton, matching this repo's existing
enum style (`DashSection`, `NotifSection`):

```qml
readonly property string fajr: "fajr"
readonly property string sunrise: "sunrise"
readonly property string dhuhr: "dhuhr"
readonly property string asr: "asr"
readonly property string maghrib: "maghrib"
readonly property string isha: "isha"
readonly property var values: [fajr, sunrise, dhuhr, asr, maghrib, isha]
readonly property var alerting: [fajr, dhuhr, asr, maghrib, isha]
readonly property var labels: ({ fajr: "Fajr", sunrise: "Shurūq", dhuhr: "Dhuhr",
                                 asr: "Asr", maghrib: "Maghrib", isha: "Isha" })
```

### Layer 2 — services

**`services/Geo.qml`** — network only. Owns **no persistence**, which is what
keeps it acyclic with `Prayer`.

```
property var detected            // { lat, lon, city, country, tz } | null
property bool detecting
property string error
property var results             // city-search results, max 5
property bool searching
property var zoneOffsets         // { "Africa/Algiers": 60, ... } minutes

function detect(): void          // one-shot, startup + manual
function search(query: string): void
function clearResults(): void
function offsetFor(tz: string): int   // minutes, NaN if unknown
```

- Detection: `curl -sf --max-time <Appearance.prayer.requestTimeout>
  https://ipapi.co/json/`, parsed for `latitude`, `longitude`, `city`,
  `country_code`, `timezone`. **It does not return elevation** — detected and
  cached places therefore carry `elevation: 0`.
- Search: `curl -sf --max-time <Appearance.prayer.requestTimeout>
  "https://geocoding-api.open-meteo.com/v1/search?name=<q>&count=5&format=json"`
  — free, keyless, returns `latitude`, `longitude`, `name`, `country_code`,
  `timezone`, `elevation`. Query is URL-encoded; the `Process` `command` array
  form means no shell interpolation and therefore no injection surface.

**Elevation is fixed at 0 and is never applied.** Corrected 2026-09-08 after
measurement — an earlier draft of this spec claimed 1080 m was worth "about a
minute". It is not. Feeding Tiaret's real 1080 m into `riseSetAngle` moves
sunrise 6 minutes earlier and Maghrib 7 minutes later than the published
timetable:

```
elevation 1080 → Maghrib 18:12    elevation 0 → Maghrib 18:05    (15-01-2026)
```

AlAdhan, and effectively every mainstream timetable, computes at sea level. A
Maghrib seven minutes later than the local mosque's is a real problem — that is
the iftar time in Ramadan. So `riseSetAngle` is always called with `0`, and the
`elevation` field returned by the geocoder is stored but unused.

`Prayers.fallbackPlace.elevation` is therefore `0`, not `1080`.
- Zone offsets reuse the exact idiom already proven in `services/Time.qml`:
  `sh -c 'for z in "$@"; do TZ="$z" date +%z; done'`.
- **Detection runs once at startup and never on a repeating timer.** A retry
  loop against a free rate-limited endpoint is how you get silently banned.
  Failure surfaces as `error` and waits for the user.

**`services/Prayer.qml`** — the store, the settings, and the computation.

```
readonly property var place        // pinned ?? Geo.detected ?? cached ?? fallback
readonly property string source    // "pinned" | "detected" | "cached" | "fallback"
readonly property bool zoneMismatch
property string method             // Prayers.methods id
property string asr                // Prayers.asrSchools id
property string highLat            // Prayers.highLatRules id

readonly property var today        // [{ name, date, label }] x6, ascending
readonly property var yesterday
readonly property var tomorrow
readonly property var current      // the interval we are inside  | null
readonly property var next         // the upcoming prayer entry
readonly property int minutesToNext
readonly property real progress    // 0..1 through the current interval

function pin(place): void
function unpin(): void
function setMethod(id): void
function setAsr(id): void
function setHighLat(id): void
```

Persistence is a `FileView` on `${Paths.state}/quickshell/prayer.json` with
`atomicWrites: true` and `printErrors: false`, preceded by a one-shot
`mkdir -p` `Process` — the same three-part idiom as
`services/NotifHistory.qml:222`. Writes are debounced.

A **three-day window** is computed, not one. Yesterday is needed because at
01:00 the interval you are inside began at yesterday's Isha; tomorrow is needed
because after Isha the next prayer is tomorrow's Fajr. Computing only "today"
produces a null `current` after midnight and a null `next` after Isha.

**`services/PrayerAlerts.qml`** — the scheduler, and the only file that shells
out to `notify-send`.

### Layer 3 — UI

```
modules/dashboard/prayers/PrayerPane.qml        RowLayout, 3 columns
modules/dashboard/prayers/PrayerNextCard.qml    next prayer + countdown + GaugeArc
modules/dashboard/prayers/PrayerListCard.qml    the six rows
modules/dashboard/prayers/PrayerRow.qml         one row
modules/dashboard/prayers/PrayerPlaceCard.qml   place, source chip, search, pin
modules/dashboard/prayers/PrayerSearchRow.qml   one search result
modules/dashboard/prayers/PrayerSettingsCard.qml method / Asr / high-lat
modules/bar/components/PrayerPill.qml           centre-bar pill
```

One component per file; no inline sub-components, matching the repo's existing
rule.

### Existing files modified

| File | Change |
| --- | --- |
| `core/enums/DashSection.qml` | `+ prayers` |
| `core/enums/BarEntry.qml` | `+ prayers` |
| `core/config/Icons.qml` | `+ prayersTab`, `+ mosque`, `+ pin`, `+ pinOff` |
| `core/config/Appearance.qml` | `+ component PrayerConfig` and `readonly property PrayerConfig prayer` |
| `core/config/Appearance.qml` | `entriesCentre: [worldClock, prayers]` |
| `modules/dashboard/DashState.qml` | `sections` gains `DashSection.prayers` |
| `modules/dashboard/DashboardPanel.qml` | tab entry, `DelegateChoice`, import |
| `modules/bar/BarSlot.qml` | `DelegateChoice` for `BarEntry.prayers` |
| `modules/bar/BarContent.qml` | separator between centre entries |
| `probe.qml` | new singletons and properties referenced |
| `docs/prayers.md` | new — how it works, what to change when |

---

## 3. Data model

`${XDG_STATE_HOME}/quickshell/prayer.json`:

```json
{
  "pinned": {
    "lat": 35.3711, "lon": 1.3170, "elevation": 0,
    "city": "Tiaret", "country": "DZ", "tz": "Africa/Algiers"
  },
  "cached": { "…same shape, last successful IP detection…" },
  "method": "mwl",
  "asr": "standard",
  "highLat": "angle"
}
```

`pinned` is `null` when the user is following IP detection. `cached` exists so a
cold boot with no network still shows the last known place rather than falling
all the way back.

The hardcoded fallback is **Tiaret**, not Greenwich. A shell that has never had
network and has an empty state file should still show this user's correct times.

---

## 4. Timezone handling — the decision that matters most

Times are computed against **the system's local UTC offset**, obtained as
`-new Date(y, m, d, 12).getTimezoneOffset() / 60` for the target date. Taking it
at local noon of that specific date makes it DST-correct without any date
library, and without depending on `Intl` support in Qt's V4 engine, which is not
guaranteed.

The place's own `tz` name is used for **one purpose only**: detecting that it
disagrees with the system. `Geo.offsetFor(place.tz)` is compared against the
system offset, and a mismatch raises `Prayer.zoneMismatch`.

This is deliberate. If the IP says Edmonton while the laptop clock is still on
`Africa/Algiers`, then *every* clock on the machine is wrong, not just this
panel — and a prayer panel quietly rendering Edmonton times against an Algiers
clock is worse than one that says plainly:

> Location is Edmonton but your system clock is on Africa/Algiers. Times may be
> wrong until you change your system timezone.

Silence here produces numbers that look entirely plausible and are hours off.

---

## 5. Computation

For each of the three days:

1. Seed fractional-day guesses: `fajr 5/24, sunrise 6/24, dhuhr 12/24,
   asr 13/24, sunset 18/24, isha 18/24`.
2. Compute each time from its guess.
3. **Run the whole pass a second time** using the first pass's results as the
   guesses. Declination depends on the time of day being solved for, so one
   refinement pass is required for minute-level accuracy.
4. Apply `-lon / 15` then `+ utcOffsetHours`.
5. Apply the high-latitude rule.
6. Convert fractional hours to a `Date` on that calendar day.

```
fajr    = sunAngleTime(method.fajr, t.fajr, ccw)
sunrise = sunAngleTime(riseSetAngle(elevation), t.sunrise, ccw)
dhuhr   = midDay(t.dhuhr)
asr     = asrTime(asrFactor, t.asr)
maghrib = sunAngleTime(riseSetAngle(elevation), t.sunset, cw)
isha    = method.ishaMinutes ? maghrib + ishaMinutes / 60
                             : sunAngleTime(method.isha, t.isha, cw)
```

### High-latitude adjustment

```
night   = timeDiff(maghrib, sunrise)
portion(angle) = { angle: night * angle / 60,
                   midnight: night / 2,
                   seventh: night / 7 }[rule]

fajrPortion = portion(method.fajr)
ishaPortion = portion(method.isha ?? Prayers.defaultIshaAngle)

if isNaN(fajr) or timeDiff(fajr, sunrise) > fajrPortion:
    fajr = sunrise - fajrPortion
if isNaN(isha) or timeDiff(maghrib, isha) > ishaPortion:
    isha = maghrib + ishaPortion
```

With `highLat: "none"` the adjustment is skipped and `NaN` propagates to the UI,
which renders `—`. That is an honest answer, and it is why the rule ships as
`angle` rather than `none`.

Umm al-Qura's Isha is minutes-based and has no angle, so the night portion falls
back to 18° — matching the reference implementation.

---

## 6. Alerts

`services/PrayerAlerts.qml` hangs off `Time.now`, which is already a
`SystemClock` at `Minutes` precision. **No new timer is introduced.**

```
readonly property var offsets: [20, 10, 5, 0]
property var fired: ({})

function scan(): void
    for prayer in PrayerName.alerting:
        for offset in offsets:
            target = prayerDate - offset minutes
            if sameMinute(target, Time.now) and not fired[key]:
                fired[key] = true
                emit(prayer, offset)
    prune fired keys whose day is not today

key = `${yyyy-MM-dd}|${prayer}|${offset}`

sameMinute(a, b) = a.getFullYear() === b.getFullYear()
                && a.getMonth()    === b.getMonth()
                && a.getDate()     === b.getDate()
                && a.getHours()    === b.getHours()
                && a.getMinutes()  === b.getMinutes()
```

**Exact-minute matching, not "has the time passed".** Resuming a suspended
laptop at 15:00 must not dump four hours of stale prayer warnings on the user.
An alert that was missed while the machine was asleep is not shown at all, which
is correct: it is no longer information, it is noise.

### Emission

```
["notify-send", "-u", "critical", "-a", Ids.appid,
 "-r", String(Appearance.prayer.notifyIdBase + prayerIndex),
 summary, body]
```

| Offset | Summary | Body |
| --- | --- | --- |
| 20 / 10 / 5 | `Asr in 10 minutes` | `16:42 · Tiaret` |
| 0 | `Asr — it's time` | `16:42 · Tiaret` |

`Appearance.notif.timeoutCritical` is `0`, and `Notif.arm()` (`services/Notif.qml:95`)
returns early when `timeout <= 0`. Critical notifications in this shell therefore
**never auto-dismiss** — the "urgent so I can see it" requirement is satisfied by
the existing notification path with no new code.

### Why a stable replace id

Five prayers × four alerts = twenty sticky notifications a day if nothing is
dismissed. Reusing one `-r` id per prayer means the 10-minute warning replaces
its own 20-minute one in place, so at most one live countdown exists per prayer.

**This depends on Quickshell's `NotificationServer` honouring `replaces_id`,
which is unverified.** Implementation must test this before relying on it. If it
does not replace, the fallback is four independent notifications and the
behaviour is documented in `docs/prayers.md` rather than quietly shipped.

### Duplicate protection

`fired` is in-memory. A shell reload loses it, so a reload occurring *within the
same minute as an alert* can repeat that alert once. Persisting the set would
mean a disk write per alert to prevent a once-in-a-blue-moon duplicate of a
notification the user wanted anyway. Not worth it.

---

## 7. UI

### Pane — three columns, mirroring `DashPane`'s shape

**Next** — upcoming prayer name, its time, `in 1h 23m`, and a `GaugeArc`
(`core/components/GaugeArc.qml`) showing `Prayer.progress` through the current
interval.

**Today** — six `PrayerRow`s. The current interval is highlighted with
`Colours.hover`; elapsed rows are `Colours.textMuted`; Shurūq is visually set
apart as a marker, not a prayer. A `NaN` time renders as `—`.

**Place & method** — two stacked cards:

- `PrayerPlaceCard` — city, country, coordinates, a source chip
  (*Pinned* / *Detected* / *Cached* / *Default*), the timezone-mismatch warning
  when raised, a *Detect again* button, a `TextField`
  (`core/components/TextField.qml`) that searches cities, up to five
  `PrayerSearchRow` results that pin on click, and *Unpin* when pinned.
- `PrayerSettingsCard` — method, Asr and high-latitude selectors.

### Bar pill

`modules/bar/components/PrayerPill.qml`, built on `core/components/Pill.qml`
like the existing pills. Shows glyph + transliterated short name + countdown
(`Asr 1h23`). Goes `Colours.accent` inside the last 20 minutes — the same
threshold as the first alert, so the pill and the notifications tell one story.

Clicking it opens the dashboard on the Prayers tab
(`DashState.show(DashSection.prayers)`).

**Two consequences of putting it in the centre slot, both handled:**

1. `centreSlot` is `anchors.centerIn: parent`, so a second entry pushes the
   clock off true centre. Accepted — the group is centred, and the dashboard
   anchors to the window's centre, not to the clock.
2. Only `WorldClock` currently writes `DashState.barHover`. If the pill did not,
   there would be a dead zone where moving the cursor from the clock to the pill
   closes the dashboard. **The pill's `HoverHandler` must also feed
   `DashState.barHover`**, keeping the centre group one contiguous hover target
   — as `docs/dashboard.md § Two hover sources, one state` requires.

A one-pixel `StyledRect` divider separates the two centre entries, since
`BarSlot`'s spacing is `Appearance.spacing.none`.

### `Appearance.PrayerConfig`

No magic numbers anywhere in the feature — every value below is a token, matching
how `DashConfig` and `NotifPanelConfig` are already written.

```qml
component PrayerConfig: QtObject {
    readonly property string labelPrayers: "Prayers"

    readonly property int nextWidth: 214
    readonly property int listWidth: 214
    readonly property int placeWidth: 268
    readonly property int rowHeight: 30

    readonly property int arcSize: 132
    readonly property real arcThicknessRatio: 0.1
    readonly property int nextNameSize: 22
    readonly property int nextTimeSize: 32

    readonly property string timeFormat: "HH:mm"
    readonly property string dayKeyFormat: "yyyy-MM-dd"
    readonly property string placeholder: "—"

    readonly property int searchMaxResults: 5
    readonly property int searchDebounce: 350
    readonly property int requestTimeout: 8

    readonly property var alertOffsets: [20, 10, 5, 0]
    readonly property int notifyIdBase: 9200
    readonly property int urgentWindow: 20      // minutes; pill turns accent

    readonly property int pillIconSize: 13
    readonly property int dividerWidth: 1
    readonly property real dividerOpacity: 0.25
    readonly property int dividerMargin: 8

    readonly property int saveDebounce: 500
    readonly property string stateDir: "quickshell"
    readonly property string stateFile: "prayer.json"
}
```

`urgentWindow` and `alertOffsets[0]` are both 20 by construction — the pill turns
accent at exactly the moment the first notification fires, so the two surfaces
never disagree.

---

## 8. Failure modes

| Condition | Behaviour |
| --- | --- |
| Fajr/Isha have no solution (Alberta, mid-May → late July) | Angle-based night split; times stay continuous across the blackout boundary |
| Place timezone ≠ system timezone | Explicit warning in the place card; times still shown, clearly flagged |
| No network at boot | `cached`, else Tiaret fallback. Panel fully functional |
| IP lookup fails or is rate-limited | Keep cache, show error chip, **no retry loop** |
| City search fails | Empty results + error text; existing place untouched |
| DST transition | Offset resolved per-date at local noon, so it is correct on both sides |
| Suspend / resume | Exact-minute matching means missed alerts do not backfire |
| Shell reload | At most one duplicate alert, only within that same minute |
| Maghrib and Isha < 20 min apart (high latitude) | Alerts are keyed per prayer and use distinct replace ids; they do not clobber each other |
| `NaN` anywhere | Renders `—`, never `Invalid Date` or `NaN:NaN` |
| Extreme latitude, no sunrise/sunset at all | Every time renders `—`; no crash, no infinite loop |

---

## 9. Verification

`qmllint` does not catch load failures in this config — the gate is a
non-instantiating `probe.qml` run with `qs -p`. Every new singleton and every
new `Appearance.prayer` token must be referenced there.

1. **Load gate** — `qs -p probe.qml` exits clean with the new references added.
2. **Numerical correctness** — a probe computes Tiaret
   (35.3711 N, 1.3170 E, `Africa/Algiers`, MWL, Asr factor 1) for fixed dates
   spread across the year, and diffs against reference values fetched **once,
   during implementation**, from AlAdhan. Tolerance **±1 minute**. This is the
   test that decides whether the port is trustworthy; it is not optional.
3. **High-latitude branch** — the same check for Edmonton
   (53.5461 N, −113.4938 W) in mid-June, which is the only way to exercise the
   angle-based fallback. Assert Fajr and Isha are finite and ordered.
4. **Replace-id behaviour** — verified by hand before the design depends on it.
5. **Alerts** — verified by temporarily shifting a prayer time so an alert fires
   on demand; confirm it is critical and does not auto-dismiss.
6. **Visual** — panel and pill screenshotted with the tab live.

---

## 10. Out of scope

Adhan audio; qibla direction; Hijri date; per-prayer alert customisation;
mosque-specific minute offsets; monthly/annual timetable view; widget on the
lock screen.
