# Prayer Times Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `Prayers` tab to the dashboard drawer, a prayer pill in the centre bar, and critical desktop notifications at 20 / 10 / 5 minutes before each prayer and at the prayer time itself.

**Architecture:** Three layers. `core/helpers/Solar.qml` is pure astronomy with no I/O and is the only thing that computes a time. `services/Geo.qml` touches the network (IP detection, city search) and owns no persistence. `services/Prayer.qml` owns the JSON state file, the settings, and a three-day window of computed times; `services/PrayerAlerts.qml` is the only file that shells out to `notify-send`. UI reads the services and never computes.

**Tech Stack:** Quickshell (Qt 6 / QML), `curl` via `Quickshell.Io.Process`, `notify-send` (libnotify), `FileView` with `atomicWrites` for persistence.

**Spec:** `docs/superpowers/specs/2026-09-08-prayer-times-design.md`

## Global Constraints

- **No comments in QML.** Not explanatory, not doc blocks. The only permitted comment forms are tool directives (`eslint-disable`-style pragmas). Naming carries intent.
- **No magic numbers or strings.** Every literal goes in `Appearance.PrayerConfig`, `core/constants/Prayers.qml`, or `core/enums/PrayerName.qml`.
- **One component per file.** No inline sub-components, no `renderX` helpers. `Repeater` delegates written inline are fine — that is the existing pattern (`WorldClockCard.qml`).
- **File naming:** `PascalCase.qml` for components and singletons, matching the existing tree.
- **Enums are `Singleton` objects of `readonly property string`** plus a `values` list. Never the QML `enum` keyword.
- **Singletons in `services/` reference each other directly without an import** (see `services/Notifs.qml` using `Lock` and `NotifHistory`). Only cross-directory access needs `import qs.services`.
- **The load gate is `qs -p`, not `qmllint`.** `qmllint` does not catch these failures.
- **`Qt.exit()` and `Quickshell.quit()` do not work under Quickshell** — both were tested on 2026-09-08 and neither terminates the process. Every headless check must be run under `timeout` and judged by grepping stdout. **Never judge a headless QML check by its exit code** — it will always be 124.
- **Elevation is always passed as `0`.** Never pass a real elevation into `riseSetAngle`. See spec § 2.
- Working directory for every command below is `/home/sidouxp3/.config/quickshell`.

---

### Task 1: Solar helper and the numeric verification harness

The whole feature is worthless if the arithmetic is wrong, so this task is first and it is the only task with a hard numeric pass/fail. The reference table was measured against AlAdhan (method 3 = MWL, school 0) on 2026-09-08; a scratch implementation of these exact formulae reproduced it with a worst delta of 1 minute.

**Files:**
- Create: `core/helpers/Solar.qml`
- Create: `check_prayer.qml` (repo root — `qs.` imports resolve relative to the config root, so this file cannot live in a subdirectory)

**Interfaces:**
- Consumes: nothing.
- Produces: `Solar.timesFor(params) -> { fajr, sunrise, dhuhr, asr, sunset, maghrib, isha }` in fractional local hours. Values may exceed 24 (Edmonton's Isha is 24.07) and may be `NaN`. Callers must handle both. Also `Solar.fix(value, span)`, `Solar.fixHour(value)`, `Solar.timeDiff(from, to)`, `Solar.julianDay(y, m, d)`, `Solar.sunPosition(jd)`, `Solar.riseSetAngle(elevation)`.

- [ ] **Step 1: Write the failing check harness**

Create `check_prayer.qml`:

```qml
import QtQuick
import Quickshell
import qs.core.helpers

ShellRoot {
    id: root

    readonly property var keys: ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha"]

    readonly property var cases: [
        {
            name: "Tiaret 15-01-2026",
            year: 2026, month: 1, day: 15, lat: 35.3711, lon: 1.3170, tzHours: 1,
            expect: ["06:34", "08:03", "13:04", "15:45", "18:05", "19:30"]
        },
        {
            name: "Tiaret 21-03-2026",
            year: 2026, month: 3, day: 21, lat: 35.3711, lon: 1.3170, tzHours: 1,
            expect: ["05:32", "06:57", "13:02", "16:28", "19:07", "20:27"]
        },
        {
            name: "Tiaret 15-06-2026",
            year: 2026, month: 6, day: 15, lat: 35.3711, lon: 1.3170, tzHours: 1,
            expect: ["03:51", "05:39", "12:55", "16:44", "20:11", "21:52"]
        },
        {
            name: "Tiaret 08-09-2026",
            year: 2026, month: 9, day: 8, lat: 35.3711, lon: 1.3170, tzHours: 1,
            expect: ["05:05", "06:32", "12:52", "16:28", "19:12", "20:34"]
        },
        {
            name: "Tiaret 21-12-2026",
            year: 2026, month: 12, day: 21, lat: 35.3711, lon: 1.3170, tzHours: 1,
            expect: ["06:28", "08:00", "12:53", "15:28", "17:46", "19:12"]
        },
        {
            name: "Edmonton 15-06-2026",
            year: 2026, month: 6, day: 15, lat: 53.5461, lon: -113.4938, tzHours: -6,
            expect: ["02:58", "05:04", "13:35", "18:01", "22:05", "00:04"]
        }
    ]

    function pad(value: int): string {
        return value < 10 ? `0${value}` : `${value}`;
    }

    function hhmm(hours: real): string {
        if (isNaN(hours))
            return "--:--";

        const wrapped = Solar.fix(hours + 0.5 / 60, 24);
        const h = Math.floor(wrapped);
        return `${root.pad(h)}:${root.pad(Math.floor((wrapped - h) * 60))}`;
    }

    function minutes(text: string): int {
        return Number(text.slice(0, 2)) * 60 + Number(text.slice(3));
    }

    function delta(got: string, expected: string): int {
        const raw = root.minutes(got) - root.minutes(expected) + 720;
        return ((raw % 1440) + 1440) % 1440 - 720;
    }

    Component.onCompleted: {
        let worst = 0;
        let failures = 0;

        for (const item of root.cases) {
            const times = Solar.timesFor({
                year: item.year,
                month: item.month,
                day: item.day,
                lat: item.lat,
                lon: item.lon,
                elevation: 0,
                tzHours: item.tzHours,
                fajrAngle: 18,
                ishaAngle: 17,
                ishaMinutes: 0,
                asrFactor: 1,
                highLat: "angle"
            });

            const got = root.keys.map(key => root.hhmm(times[key]));
            let bad = 0;

            for (let i = 0; i < root.keys.length; i++) {
                const off = Math.abs(root.delta(got[i], item.expect[i]));
                worst = Math.max(worst, off);
                if (off > 1)
                    bad++;
            }

            if (bad > 0)
                failures++;

            console.log(`${bad > 0 ? "FAIL" : "ok  "} ${item.name}  got ${got.join(" ")}  exp ${item.expect.join(" ")}`);
        }

        console.log(`PRAYER-CHECK ${failures === 0 ? "PASS" : "FAIL"} worst=${worst}min cases=${root.cases.length} failures=${failures}`);
    }
}
```

- [ ] **Step 2: Run the harness to verify it fails**

```bash
timeout 20 qs -p check_prayer.qml 2>&1 | grep -E "PRAYER-CHECK|Solar"
```

Expected: a QML error naming `Solar` as unavailable, and **no** `PRAYER-CHECK` line. The command will take the full 20 seconds and exit 124 — that is normal and is not the result.

- [ ] **Step 3: Implement `core/helpers/Solar.qml`**

```qml
pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property real toDegrees: 180 / Math.PI
    readonly property real toRadians: Math.PI / 180

    function dsin(value: real): real {
        return Math.sin(value * root.toRadians);
    }

    function dcos(value: real): real {
        return Math.cos(value * root.toRadians);
    }

    function dtan(value: real): real {
        return Math.tan(value * root.toRadians);
    }

    function darcsin(value: real): real {
        return Math.asin(value) * root.toDegrees;
    }

    function darccos(value: real): real {
        return value < -1 || value > 1 ? NaN : Math.acos(value) * root.toDegrees;
    }

    function darctan2(y: real, x: real): real {
        return Math.atan2(y, x) * root.toDegrees;
    }

    function darccot(value: real): real {
        return Math.atan2(1, value) * root.toDegrees;
    }

    function fix(value: real, span: real): real {
        const wrapped = value - span * Math.floor(value / span);
        return wrapped < 0 ? wrapped + span : wrapped;
    }

    function fixAngle(value: real): real {
        return root.fix(value, 360);
    }

    function fixHour(value: real): real {
        return root.fix(value, 24);
    }

    function timeDiff(from: real, to: real): real {
        return root.fixHour(to - from);
    }

    function julianDay(year: int, month: int, day: int): real {
        let y = year;
        let m = month;

        if (m <= 2) {
            y -= 1;
            m += 12;
        }

        const a = Math.floor(y / 100);
        const b = 2 - a + Math.floor(a / 4);

        return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + day + b - 1524.5;
    }

    function sunPosition(jd: real): var {
        const d = jd - 2451545;
        const g = root.fixAngle(357.529 + 0.98560028 * d);
        const q = root.fixAngle(280.459 + 0.98564736 * d);
        const l = root.fixAngle(q + 1.915 * root.dsin(g) + 0.020 * root.dsin(2 * g));
        const e = 23.439 - 0.00000036 * d;
        const ra = root.fixHour(root.darctan2(root.dcos(e) * root.dsin(l), root.dcos(l)) / 15);
        const raw = q / 15 - ra;

        return {
            declination: root.darcsin(root.dsin(e) * root.dsin(l)),
            equation: raw - 24 * Math.round(raw / 24)
        };
    }

    function midDay(jd: real, t: real): real {
        return root.fixHour(12 - root.sunPosition(jd + t).equation);
    }

    function sunAngleTime(jd: real, lat: real, angle: real, t: real, ccw: bool): real {
        const declination = root.sunPosition(jd + t).declination;
        const ratio = (-root.dsin(angle) - root.dsin(declination) * root.dsin(lat)) / (root.dcos(declination) * root.dcos(lat));
        const offset = root.darccos(ratio) / 15;

        if (isNaN(offset))
            return NaN;

        return root.midDay(jd, t) + (ccw ? -offset : offset);
    }

    function asrTime(jd: real, lat: real, factor: real, t: real): real {
        const declination = root.sunPosition(jd + t).declination;
        const angle = -root.darccot(factor + root.dtan(Math.abs(lat - declination)));

        return root.sunAngleTime(jd, lat, angle, t, false);
    }

    function riseSetAngle(elevation: real): real {
        return 0.833 + 0.0347 * Math.sqrt(Math.max(elevation, 0));
    }

    function nightPortion(rule: string, angle: real, night: real): real {
        if (rule === "angle")
            return night * angle / 60;
        if (rule === "midnight")
            return night / 2;
        if (rule === "seventh")
            return night / 7;

        return NaN;
    }

    function timesFor(params: var): var {
        const jd = root.julianDay(params.year, params.month, params.day) - params.lon / (15 * 24);
        const horizon = root.riseSetAngle(params.elevation);

        let guess = {
            fajr: 5 / 24,
            sunrise: 6 / 24,
            dhuhr: 12 / 24,
            asr: 13 / 24,
            sunset: 18 / 24,
            isha: 18 / 24
        };
        let pass = {};

        for (let round = 0; round < 2; round++) {
            pass = {
                fajr: root.sunAngleTime(jd, params.lat, params.fajrAngle, guess.fajr, true),
                sunrise: root.sunAngleTime(jd, params.lat, horizon, guess.sunrise, true),
                dhuhr: root.midDay(jd, guess.dhuhr),
                asr: root.asrTime(jd, params.lat, params.asrFactor, guess.asr),
                sunset: root.sunAngleTime(jd, params.lat, horizon, guess.sunset, false)
            };
            pass.isha = params.ishaMinutes > 0 ? pass.sunset + params.ishaMinutes / 60 : root.sunAngleTime(jd, params.lat, params.ishaAngle, guess.isha, false);

            const refined = {};
            for (const key in pass)
                refined[key] = isNaN(pass[key]) ? guess[key] : pass[key] / 24;
            guess = refined;
        }

        const shift = params.tzHours - params.lon / 15;
        const times = {};
        for (const key in pass)
            times[key] = pass[key] + shift;

        return root.adjustHighLats(times, params);
    }

    function adjustHighLats(times: var, params: var): var {
        const night = root.timeDiff(times.sunset, times.sunrise);
        const fajrPortion = root.nightPortion(params.highLat, params.fajrAngle, night);
        const ishaAngle = params.ishaMinutes > 0 ? 18 : params.ishaAngle;
        const ishaPortion = root.nightPortion(params.highLat, ishaAngle, night);

        if (!isNaN(fajrPortion) && (isNaN(times.fajr) || root.timeDiff(times.fajr, times.sunrise) > fajrPortion))
            times.fajr = times.sunrise - fajrPortion;

        if (!isNaN(ishaPortion) && (isNaN(times.isha) || root.timeDiff(times.sunset, times.isha) > ishaPortion))
            times.isha = times.sunset + ishaPortion;

        times.maghrib = times.sunset;

        return times;
    }
}
```

- [ ] **Step 4: Run the harness to verify it passes**

```bash
timeout 20 qs -p check_prayer.qml 2>&1 | grep -E "^\s*DEBUG|PRAYER-CHECK|FAIL"
```

Expected, exactly:

```
PRAYER-CHECK PASS worst=1min cases=6 failures=0
```

If `worst` exceeds 1, **stop**. Do not adjust the tolerance and do not edit the expected table — those numbers are measured reference values. Debug `Solar` instead. The most likely culprits, in order: the `equation` normalisation (`raw - 24 * Math.round(raw / 24)`, which must produce a value in roughly `[-12, 12)`, not `fixHour`); the longitude term in `julianDay` (`- params.lon / (15 * 24)`); and the two-round refinement loop being run only once.

- [ ] **Step 5: Verify the high-latitude case specifically**

```bash
timeout 20 qs -p check_prayer.qml 2>&1 | grep Edmonton
```

Expected: `ok   Edmonton 15-06-2026  got 02:58 05:04 13:35 18:01 22:05 00:04 …`

This row is the whole reason the high-latitude rule exists. On that date in Edmonton the sun never reaches 18° below the horizon, so `sunAngleTime` returns `NaN` for both Fajr and Isha and `adjustHighLats` supplies them. Isha's raw value is `24.07` — past midnight. If it reads `00:04` here the overflow is being handled; if it reads `--:--` the `NaN` path is broken, and if it reads something near `22:05` the night portion is being applied to the wrong base.

---

### Task 2: Constants, enums, appearance tokens, and icons

Pure data. Everything later tasks reference by name is defined here, so nothing downstream has to invent a literal.

**Files:**
- Create: `core/constants/Prayers.qml`
- Create: `core/enums/PrayerName.qml`
- Modify: `core/config/Appearance.qml` (add `PrayerConfig` component, the `prayer` property, and `labelPrayers` on `DashConfig`)
- Modify: `core/config/Icons.qml` (add five glyphs)
- Modify: `probe.qml`

**Interfaces:**
- Consumes: nothing.
- Produces: `Prayers.methods`, `Prayers.asrSchools`, `Prayers.highLatRules`, `Prayers.fallbackPlace`, `Prayers.defaultMethod`, `Prayers.defaultAsr`, `Prayers.defaultHighLat`, `Prayers.defaultIshaAngle`; `PrayerName.{fajr,sunrise,dhuhr,asr,maghrib,isha,values,alerting,labels}`; `Appearance.prayer.*`; `Appearance.dash.labelPrayers`; `Icons.{prayersTab,place,pin,pinOff,sunriseMarker}`.

- [ ] **Step 1: Create `core/constants/Prayers.qml`**

```qml
pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property var methods: [
        {
            id: "mwl",
            label: "Muslim World League",
            fajr: 18,
            isha: 17,
            ishaMinutes: 0
        },
        {
            id: "algeria",
            label: "Algeria (Ministry)",
            fajr: 18,
            isha: 17,
            ishaMinutes: 0
        },
        {
            id: "isna",
            label: "ISNA (North America)",
            fajr: 15,
            isha: 15,
            ishaMinutes: 0
        },
        {
            id: "egypt",
            label: "Egyptian Authority",
            fajr: 19.5,
            isha: 17.5,
            ishaMinutes: 0
        },
        {
            id: "makkah",
            label: "Umm al-Qura",
            fajr: 18.5,
            isha: 0,
            ishaMinutes: 90
        },
        {
            id: "karachi",
            label: "Karachi",
            fajr: 18,
            isha: 18,
            ishaMinutes: 0
        }
    ]

    readonly property var asrSchools: [
        {
            id: "standard",
            label: "Standard",
            factor: 1
        },
        {
            id: "hanafi",
            label: "Hanafi",
            factor: 2
        }
    ]

    readonly property var highLatRules: [
        {
            id: "angle",
            label: "Angle"
        },
        {
            id: "midnight",
            label: "Midnight"
        },
        {
            id: "seventh",
            label: "Seventh"
        },
        {
            id: "none",
            label: "None"
        }
    ]

    readonly property var fallbackPlace: ({
            lat: 35.3711,
            lon: 1.3170,
            city: "Tiaret",
            country: "DZ",
            tz: "Africa/Algiers"
        })

    readonly property string defaultMethod: "mwl"
    readonly property string defaultAsr: "standard"
    readonly property string defaultHighLat: "angle"
    readonly property real defaultIshaAngle: 18
}
```

- [ ] **Step 2: Create `core/enums/PrayerName.qml`**

```qml
pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string fajr: "fajr"
    readonly property string sunrise: "sunrise"
    readonly property string dhuhr: "dhuhr"
    readonly property string asr: "asr"
    readonly property string maghrib: "maghrib"
    readonly property string isha: "isha"

    readonly property var values: [root.fajr, root.sunrise, root.dhuhr, root.asr, root.maghrib, root.isha]
    readonly property var alerting: [root.fajr, root.dhuhr, root.asr, root.maghrib, root.isha]

    readonly property var labels: ({
            fajr: "Fajr",
            sunrise: "Shurūq",
            dhuhr: "Dhuhr",
            asr: "Asr",
            maghrib: "Maghrib",
            isha: "Isha"
        })
}
```

- [ ] **Step 3: Add `PrayerConfig` to `core/config/Appearance.qml`**

Insert the component alongside the other `component XConfig: QtObject` blocks (near `DashConfig`, around line 236):

```qml
    component PrayerConfig: QtObject {
        readonly property int nextWidth: 214
        readonly property int listWidth: 214
        readonly property int placeWidth: 268
        readonly property int rowHeight: 26
        readonly property int optionHeight: 26
        readonly property int optionRounding: 8

        readonly property int arcSize: 132
        readonly property real arcThicknessRatio: 0.1
        readonly property real arcStart: -90
        readonly property real arcSpan: 360
        readonly property int nextNameSize: 20
        readonly property int nextTimeSize: 30

        readonly property string timeFormat: "HH:mm"
        readonly property string dayKeyFormat: "yyyy-MM-dd"
        readonly property string placeholder: "—"
        readonly property string coordFormat: "%1, %2"
        readonly property int coordPrecision: 3

        readonly property int searchMaxResults: 5
        readonly property int searchDebounce: 350
        readonly property int searchMinLength: 2
        readonly property int requestTimeout: 8

        readonly property var alertOffsets: [20, 10, 5, 0]
        readonly property int notifyIdBase: 9200
        readonly property int urgentWindow: 20

        readonly property int pillIconSize: 13
        readonly property int dividerWidth: 1
        readonly property real dividerOpacity: 0.25
        readonly property int dividerMargin: 8
        readonly property int dividerHeight: 14

        readonly property int saveDebounce: 500
        readonly property string stateDir: "quickshell"
        readonly property string stateFile: "prayer.json"

        readonly property string labelToday: "Today"
        readonly property string labelPlace: "Location"
        readonly property string labelMethod: "Method"
        readonly property string labelAsr: "Asr"
        readonly property string labelHighLat: "High latitude"
        readonly property string labelDetect: "Detect again"
        readonly property string labelUnpin: "Use detected location"
        readonly property string labelSearch: "Search for a city"
        readonly property string labelDetecting: "Detecting…"
        readonly property string labelSearching: "Searching…"
        readonly property string labelNoResults: "No matches"
        readonly property string sourcePinned: "Pinned"
        readonly property string sourceDetected: "Detected"
        readonly property string sourceCached: "Cached"
        readonly property string sourceFallback: "Default"
        readonly property string zoneWarning: "Location is %1 but your system clock is %2. Times may be wrong until you change your system timezone."
    }
```

Register it next to the other config properties (near line 1055):

```qml
    readonly property PrayerConfig prayer: PrayerConfig {}
```

Add the tab label to the existing `DashConfig` block, beside `labelDash` / `labelPerformance` / `labelMedia`, because that is where the other dashboard tab labels already live:

```qml
        readonly property string labelPrayers: "Prayers"
```

- [ ] **Step 4: Add glyphs to `core/config/Icons.qml`**

Nerd Font glyphs in this repo are written as UTF-16 surrogate pairs. These five were generated with python on 2026-09-08:

```qml
    readonly property string prayersTab: "󱘓"
    readonly property string place: "󰍎"
    readonly property string pin: "󰐃"
    readonly property string pinOff: "󰐄"
    readonly property string sunriseMarker: "󰾜"
```

To generate any further glyph, do not type it by hand:

```bash
python3 -c "
cp = 0xF1613
e = chr(cp).encode('utf-16-be')
print(''.join('\\\\u%04X' % ((e[i]<<8)|e[i+1]) for i in range(0, len(e), 2)))
"
```

Codepoint guesses are unreliable — `U+F0198` was expected to be `crosshairs-gps` and is already in this file as `shield`. The screenshot in Task 11 is what confirms these five render as intended.

- [ ] **Step 5: Add references to `probe.qml`**

Add `qs.core.constants` and `qs.core.enums` to the imports if absent, then add to the `probes` array:

```qml
        Prayers.methods,
        Prayers.asrSchools,
        Prayers.highLatRules,
        Prayers.fallbackPlace,
        Prayers.defaultIshaAngle,
        PrayerName.values,
        PrayerName.alerting,
        PrayerName.labels,
        Appearance.prayer.alertOffsets,
        Appearance.prayer.notifyIdBase,
        Appearance.prayer.zoneWarning,
        Appearance.dash.labelPrayers,
        Icons.prayersTab,
        Icons.place,
        Icons.pin,
        Icons.pinOff,
        Icons.sunriseMarker,
        Solar.julianDay(2026, 9, 8),
        Solar.riseSetAngle(0),
```

- [ ] **Step 6: Run the load gate**

```bash
timeout 20 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
```

Expected: a `Configuration Loaded` line and no error or warning lines. The `qt.qpa.services` portal warning is pre-existing noise on this machine and is filtered out.

---

### Task 3: Geo service

Network only. This service must never be asked for a prayer time, and it must never write to disk.

**Files:**
- Create: `services/Geo.qml`
- Modify: `probe.qml`

**Interfaces:**
- Consumes: `Appearance.prayer.requestTimeout`, `Appearance.prayer.searchMaxResults`, `Appearance.prayer.searchMinLength`, `Appearance.prayer.searchDebounce`.
- Produces: `Geo.detected` (`{ lat, lon, city, country, tz }` or `null`), `Geo.detecting` (bool), `Geo.error` (string), `Geo.results` (array of the same place shape), `Geo.searching` (bool), `Geo.detect()`, `Geo.search(query)`, `Geo.clearResults()`, `Geo.requestZone(tz)` (resolves and caches one zone offset; called by `Prayer` when the place changes), `Geo.offsetFor(tz)` (minutes east of UTC, `NaN` when unknown — returns `NaN` until `requestZone` has completed for that zone, so `zoneMismatch` is false until then rather than spuriously true).

- [ ] **Step 1: Create `services/Geo.qml`**

```qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config

Singleton {
    id: root

    property var detected: null
    property bool detecting: false
    property string error: ""
    property var results: []
    property bool searching: false
    property var zoneOffsets: ({})

    property string pendingQuery: ""

    function detect(): void {
        if (root.detecting)
            return;

        root.detecting = true;
        root.error = "";
        locator.running = true;
    }

    function search(query: string): void {
        root.pendingQuery = query.trim();

        if (root.pendingQuery.length < Appearance.prayer.searchMinLength) {
            root.clearResults();
            debounce.stop();
            return;
        }

        debounce.restart();
    }

    function clearResults(): void {
        root.results = [];
        root.searching = false;
    }

    function offsetFor(tz: string): int {
        const offset = root.zoneOffsets[tz];
        return offset === undefined ? NaN : offset;
    }

    function requestZone(tz: string): void {
        if (!tz || root.zoneOffsets[tz] !== undefined)
            return;

        zoneProbe.command = ["sh", "-c", 'TZ="$1" date +%z', "sh", tz];
        zoneProbe.pending = tz;
        zoneProbe.running = true;
    }

    function applyDetection(payload: string): void {
        root.detecting = false;

        try {
            const data = JSON.parse(payload);

            if (typeof data.latitude !== "number" || typeof data.longitude !== "number") {
                root.error = data.reason ?? data.error ?? "Location lookup failed";
                return;
            }

            root.detected = {
                lat: data.latitude,
                lon: data.longitude,
                city: data.city ?? "",
                country: data.country_code ?? "",
                tz: data.timezone ?? ""
            };
            root.error = "";
        } catch (parseError) {
            root.error = "Location lookup failed";
        }
    }

    function applySearch(payload: string): void {
        root.searching = false;

        try {
            const data = JSON.parse(payload);
            const found = data.results ?? [];

            root.results = found.slice(0, Appearance.prayer.searchMaxResults).map(item => ({
                        lat: item.latitude,
                        lon: item.longitude,
                        city: item.name,
                        country: item.country_code ?? "",
                        tz: item.timezone ?? ""
                    }));
        } catch (parseError) {
            root.results = [];
        }
    }

    function applyZone(payload: string): void {
        const match = /^([+-])(\d{2})(\d{2})$/.exec(payload.trim());
        if (!match || !zoneProbe.pending)
            return;

        const sign = match[1] === "-" ? -1 : 1;
        const next = Object.assign({}, root.zoneOffsets);
        next[zoneProbe.pending] = sign * (Number(match[2]) * 60 + Number(match[3]));
        root.zoneOffsets = next;
    }

    Timer {
        id: debounce

        interval: Appearance.prayer.searchDebounce

        onTriggered: {
            root.searching = true;
            finder.command = ["curl", "-sf", "--max-time", String(Appearance.prayer.requestTimeout), `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(root.pendingQuery)}&count=${Appearance.prayer.searchMaxResults}&format=json`];
            finder.running = true;
        }
    }

    Process {
        id: locator

        command: ["curl", "-sf", "--max-time", String(Appearance.prayer.requestTimeout), "https://ipapi.co/json/"]

        stdout: StdioCollector {
            onStreamFinished: root.applyDetection(text)
        }

        onExited: code => {
            if (code !== 0) {
                root.detecting = false;
                root.error = "Location lookup failed";
            }
        }
    }

    Process {
        id: finder

        stdout: StdioCollector {
            onStreamFinished: root.applySearch(text)
        }

        onExited: code => {
            if (code !== 0) {
                root.searching = false;
                root.results = [];
            }
        }
    }

    Process {
        id: zoneProbe

        property string pending: ""

        stdout: StdioCollector {
            onStreamFinished: root.applyZone(text)
        }
    }

    Component.onCompleted: root.detect()
}
```

Detection runs exactly once, from `Component.onCompleted`. **Do not add a repeating `Timer` around it.** `ipapi.co` is free and rate-limited; a retry loop is how the endpoint starts refusing.

- [ ] **Step 2: Add to `probe.qml`**

```qml
        Geo.detecting,
        Geo.error,
        Geo.results,
        Geo.searching,
        Geo.offsetFor("Africa/Algiers"),
```

- [ ] **Step 3: Verify the load gate and a live detection**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
```

Expected: `Configuration Loaded`, no errors.

Then confirm the endpoints themselves still behave, independently of QML:

```bash
curl -sf --max-time 8 https://ipapi.co/json/ | head -c 300; echo
curl -sf --max-time 8 "https://geocoding-api.open-meteo.com/v1/search?name=Tiaret&count=5&format=json" | head -c 300; echo
```

Expected: the first prints JSON containing `latitude`, `longitude`, `city`, `timezone`. The second prints JSON whose `results[0]` is Tiaret with `latitude` ≈ 35.37 and `timezone` `Africa/Algiers`.

If `ipapi.co` returns an error object (it rate-limits by IP), that is not a code failure — `Geo.error` is designed to carry it. Note it and continue.

---

### Task 4: Prayer service

Owns the state file, the settings, and the three-day window.

**Files:**
- Create: `services/Prayer.qml`
- Modify: `probe.qml`

**Interfaces:**
- Consumes: `Solar.timesFor`, `Prayers.*`, `PrayerName.*`, `Geo.detected`, `Geo.offsetFor`, `Time.now`, `Num.clamp01`, `Paths.state`, `Appearance.prayer.*`.
- Produces: `Prayer.place`, `Prayer.source`, `Prayer.zoneMismatch`, `Prayer.systemZoneOffset`, `Prayer.method`, `Prayer.asr`, `Prayer.highLat`, `Prayer.today` (array of `{ name, label, date, time, alerting }`), `Prayer.schedule` (three days, sorted, nulls removed), `Prayer.current`, `Prayer.next`, `Prayer.minutesToNext`, `Prayer.countdown`, `Prayer.progress`, `Prayer.urgent`, `Prayer.pin(place)`, `Prayer.unpin()`, `Prayer.setMethod(id)`, `Prayer.setAsr(id)`, `Prayer.setHighLat(id)`.

- [ ] **Step 1: Create `services/Prayer.qml`**

```qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers

Singleton {
    id: root

    property bool loaded: false
    property var pinned: null
    property var cached: null
    property string method: Prayers.defaultMethod
    property string asr: Prayers.defaultAsr
    property string highLat: Prayers.defaultHighLat

    readonly property string stateDir: `${Paths.state}/${Appearance.prayer.stateDir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.prayer.stateFile}`

    readonly property var place: root.pinned ?? Geo.detected ?? root.cached ?? Prayers.fallbackPlace
    readonly property string source: {
        if (root.pinned)
            return Appearance.prayer.sourcePinned;
        if (Geo.detected)
            return Appearance.prayer.sourceDetected;
        if (root.cached)
            return Appearance.prayer.sourceCached;
        return Appearance.prayer.sourceFallback;
    }

    readonly property var methodConfig: Prayers.methods.find(entry => entry.id === root.method) ?? Prayers.methods[0]
    readonly property real asrFactor: (Prayers.asrSchools.find(entry => entry.id === root.asr) ?? Prayers.asrSchools[0]).factor

    readonly property int systemZoneOffset: -Time.now.getTimezoneOffset()
    readonly property int placeZoneOffset: Geo.offsetFor(root.place.tz)
    readonly property bool zoneMismatch: !isNaN(root.placeZoneOffset) && root.placeZoneOffset !== root.systemZoneOffset

    readonly property var today: root.compute(0)
    readonly property var schedule: root.compute(-1).concat(root.today).concat(root.compute(1)).filter(entry => entry.date !== null).sort((a, b) => a.date.getTime() - b.date.getTime())

    readonly property var current: {
        const past = root.schedule.filter(entry => entry.date <= Time.now);
        return past.length > 0 ? past[past.length - 1] : null;
    }
    readonly property var next: root.schedule.find(entry => entry.alerting && entry.date > Time.now) ?? null

    readonly property int minutesToNext: root.next ? Math.max(0, Math.round((root.next.date.getTime() - Time.now.getTime()) / Units.msPerMinute)) : -1
    readonly property bool urgent: root.minutesToNext >= 0 && root.minutesToNext <= Appearance.prayer.urgentWindow

    readonly property string countdown: {
        if (root.minutesToNext < 0)
            return Appearance.prayer.placeholder;

        const hours = Math.floor(root.minutesToNext / Units.minutesPerHour);
        const minutes = root.minutesToNext % Units.minutesPerHour;

        return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
    }

    readonly property real progress: {
        if (!root.current || !root.next)
            return 0;

        const span = root.next.date.getTime() - root.current.date.getTime();
        if (span <= 0)
            return 0;

        return Num.clamp01((Time.now.getTime() - root.current.date.getTime()) / span);
    }

    function compute(delta: int): var {
        const anchor = Time.now;
        const base = new Date(anchor.getFullYear(), anchor.getMonth(), anchor.getDate() + delta);
        const noon = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 12);
        const raw = Solar.timesFor({
            year: base.getFullYear(),
            month: base.getMonth() + 1,
            day: base.getDate(),
            lat: root.place.lat,
            lon: root.place.lon,
            elevation: 0,
            tzHours: -noon.getTimezoneOffset() / Units.minutesPerHour,
            fajrAngle: root.methodConfig.fajr,
            ishaAngle: root.methodConfig.isha,
            ishaMinutes: root.methodConfig.ishaMinutes,
            asrFactor: root.asrFactor,
            highLat: root.highLat
        });

        return PrayerName.values.map(name => {
            const hours = raw[name];
            const known = !isNaN(hours);
            const whole = known ? Math.floor(hours) : 0;
            const date = known ? new Date(base.getFullYear(), base.getMonth(), base.getDate(), whole, Math.round((hours - whole) * Units.minutesPerHour)) : null;

            return {
                name: name,
                label: PrayerName.labels[name],
                date: date,
                time: date ? Qt.formatDateTime(date, Appearance.prayer.timeFormat) : Appearance.prayer.placeholder,
                alerting: PrayerName.alerting.indexOf(name) !== -1
            };
        });
    }

    function pin(place: var): void {
        root.pinned = place;
        root.persist();
    }

    function unpin(): void {
        root.pinned = null;
        root.persist();
    }

    function setMethod(id: string): void {
        root.method = id;
        root.persist();
    }

    function setAsr(id: string): void {
        root.asr = id;
        root.persist();
    }

    function setHighLat(id: string): void {
        root.highLat = id;
        root.persist();
    }

    function adopt(payload: string): void {
        try {
            const data = JSON.parse(payload);

            root.pinned = data.pinned ?? null;
            root.cached = data.cached ?? null;
            root.method = data.method ?? Prayers.defaultMethod;
            root.asr = data.asr ?? Prayers.defaultAsr;
            root.highLat = data.highLat ?? Prayers.defaultHighLat;
        } catch (parseError) {
            root.pinned = null;
        }

        root.loaded = true;
    }

    function persist(): void {
        if (root.loaded)
            debounce.restart();
    }

    function flush(): void {
        store.setText(JSON.stringify({
            pinned: root.pinned,
            cached: root.cached,
            method: root.method,
            asr: root.asr,
            highLat: root.highLat
        }));
    }

    onPlaceChanged: Geo.requestZone(root.place.tz)

    Connections {
        target: Geo

        function onDetectedChanged(): void {
            if (!Geo.detected)
                return;

            root.cached = Geo.detected;
            root.persist();
        }
    }

    Timer {
        id: debounce

        interval: Appearance.prayer.saveDebounce

        onTriggered: root.flush()
    }

    Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: store

        path: root.statePath
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
        onLoadFailed: root.loaded = true
    }
}
```

- [ ] **Step 2: Add to `probe.qml`**

```qml
        Prayer.place,
        Prayer.source,
        Prayer.zoneMismatch,
        Prayer.today,
        Prayer.schedule,
        Prayer.current,
        Prayer.next,
        Prayer.countdown,
        Prayer.progress,
        Prayer.urgent,
        Prayer.methodConfig,
        Prayer.asrFactor,
```

- [ ] **Step 3: Verify the load gate**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
```

Expected: `Configuration Loaded`, no errors.

- [ ] **Step 4: Verify the service produces the right times for Tiaret**

Create a throwaway `check_service.qml` at the repo root:

```qml
import QtQuick
import Quickshell
import qs.services

ShellRoot {
    Component.onCompleted: {
        console.log("SERVICE-PLACE", JSON.stringify(Prayer.place));
        console.log("SERVICE-SOURCE", Prayer.source);
        console.log("SERVICE-TODAY", Prayer.today.map(entry => `${entry.label}=${entry.time}`).join(" "));
        console.log("SERVICE-NEXT", Prayer.next ? `${Prayer.next.label}@${Prayer.next.time}` : "none");
        console.log("SERVICE-COUNTDOWN", Prayer.countdown);
        console.log("SERVICE-SCHEDULE-LEN", Prayer.schedule.length);
    }
}
```

```bash
timeout 20 qs -p check_service.qml 2>&1 | grep SERVICE-
```

Expected: `SERVICE-SCHEDULE-LEN` is `18` (three days × six entries) when no time is `NaN`. `SERVICE-TODAY` must match the row for today's date computed by:

```bash
curl -sf --max-time 10 "https://api.aladhan.com/v1/timings/$(date +%d-%m-%Y)?latitude=35.3711&longitude=1.3170&method=3&school=0&timezonestring=Africa/Algiers" | python3 -c "import sys,json; t=json.load(sys.stdin)['data']['timings']; print(' '.join(f'{k}={t[k]}' for k in ['Fajr','Sunrise','Dhuhr','Asr','Maghrib','Isha']))"
```

within ±1 minute — **but only if `SERVICE-PLACE` is Tiaret.** If IP detection placed you elsewhere, the comparison is meaningless; re-run the AlAdhan call with the detected coordinates instead.

- [ ] **Step 5: Delete the throwaway and commit**

```bash
rm check_service.qml
```

`check_prayer.qml` stays — it is the permanent regression gate. `check_service.qml` does not; it depends on today's date and the live network.

---

### Task 5: PrayerAlerts service

The only file that emits notifications.

**Files:**
- Create: `services/PrayerAlerts.qml`
- Modify: `probe.qml`

**Interfaces:**
- Consumes: `Prayer.schedule`, `Prayer.place`, `Time.now`, `PrayerName.alerting`, `Ids.appid`, `Appearance.prayer.{alertOffsets,notifyIdBase,dayKeyFormat}`, `Units.msPerMinute`.
- Produces: `PrayerAlerts.fired` (object keyed `yyyy-MM-dd|name|offset`), `PrayerAlerts.scan()`, `PrayerAlerts.queue`.

- [ ] **Step 1: Create `services/PrayerAlerts.qml`**

```qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums

Singleton {
    id: root

    property var fired: ({})
    property var queue: []

    function sameMinute(a: date, b: date): bool {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate() && a.getHours() === b.getHours() && a.getMinutes() === b.getMinutes();
    }

    function scan(): void {
        const now = Time.now;
        const dayKey = Qt.formatDateTime(now, Appearance.prayer.dayKeyFormat);
        const kept = {};

        for (const key in root.fired)
            if (key.indexOf(`${dayKey}|`) === 0)
                kept[key] = true;

        for (const entry of Prayer.schedule) {
            if (!entry.alerting)
                continue;

            for (const offset of Appearance.prayer.alertOffsets) {
                const target = new Date(entry.date.getTime() - offset * Units.msPerMinute);

                if (!root.sameMinute(target, now))
                    continue;

                const key = `${dayKey}|${entry.name}|${offset}`;
                if (kept[key])
                    continue;

                kept[key] = true;
                root.enqueue(entry, offset);
            }
        }

        root.fired = kept;
    }

    function enqueue(entry: var, offset: int): void {
        const index = PrayerName.alerting.indexOf(entry.name);
        const summary = offset > 0 ? `${entry.label} in ${offset} minutes` : `${entry.label} — it's time`;
        const body = `${entry.time} · ${Prayer.place.city}`;

        root.queue = root.queue.concat([["notify-send", "-u", "critical", "-a", Ids.appid, "-r", String(Appearance.prayer.notifyIdBase + index), summary, body]]);
        root.pump();
    }

    function pump(): void {
        if (notifier.running || root.queue.length === 0)
            return;

        notifier.command = root.queue[0];
        root.queue = root.queue.slice(1);
        notifier.running = true;
    }

    Process {
        id: notifier

        onExited: root.pump()
    }

    Connections {
        target: Time

        function onNowChanged(): void {
            root.scan();
        }
    }

    Component.onCompleted: root.scan()
}
```

The queue exists because two prayers can fall within the same alert window at high latitude — Maghrib and Isha are four minutes apart in Edmonton in June — and reassigning `command` on a running `Process` loses a notification.

- [ ] **Step 2: Add to `probe.qml`**

```qml
        PrayerAlerts.fired,
        PrayerAlerts.queue,
        PrayerAlerts.sameMinute(new Date(), new Date()),
```

- [ ] **Step 3: Verify the load gate**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
```

Expected: `Configuration Loaded`, no errors.

- [ ] **Step 4: Verify a critical notification actually sticks**

Before wiring the service to real times, confirm the notification shape behaves as the design assumes:

```bash
notify-send -u critical -a quickshell -r 9200 "Asr in 10 minutes" "16:42 · Tiaret"
```

Expected: a toast appears in the running shell and **does not disappear** (`Appearance.notif.timeoutCritical` is `0`, and `services/Notif.qml:95` returns early when `timeout <= 0`).

- [ ] **Step 5: Verify the replace-id assumption**

```bash
notify-send -u critical -a quickshell -r 9200 "Asr in 20 minutes" "16:42 · Tiaret"
sleep 2
notify-send -u critical -a quickshell -r 9200 "Asr in 10 minutes" "16:42 · Tiaret"
```

Expected if `replaces_id` is honoured: **one** toast on screen, now reading "in 10 minutes".
Expected if it is not: **two** separate toasts.

Record which happened. If it is two, that is not a bug to fix here — it is a documented limitation that goes into `docs/prayers.md` in Task 11. Do not silently ship the stacking behaviour without recording it.

- [ ] **Step 6: Verify a real alert fires**

Temporarily force an alert by adding this to `PrayerAlerts.qml` `Component.onCompleted`, running the shell, then removing it:

```qml
        root.enqueue({
            name: PrayerName.asr,
            label: "Asr",
            time: "00:00",
            date: new Date(),
            alerting: true
        }, 5);
```

```bash
timeout 20 qs -p probe.qml 2>&1 | grep -iE "error" | grep -v "qt.qpa.services"
```

Expected: a critical "Asr in 5 minutes" toast appears. **Remove the temporary block before committing.**

---

### Task 6: Dashboard tab, pane skeleton, and the times list

First visible output.

**Files:**
- Modify: `core/enums/DashSection.qml`
- Modify: `modules/dashboard/DashState.qml:12`
- Modify: `modules/dashboard/DashboardPanel.qml`
- Create: `modules/dashboard/prayers/PrayerPane.qml`
- Create: `modules/dashboard/prayers/PrayerListCard.qml`
- Create: `modules/dashboard/prayers/PrayerRow.qml`

**Interfaces:**
- Consumes: `Prayer.today`, `Prayer.current`, `Time.now`, `Appearance.prayer.*`, `Icons.prayersTab`, `Appearance.dash.labelPrayers`.
- Produces: `DashSection.prayers`; `PrayerPane` with `implicitWidth` / `implicitHeight` (required — `DashboardPanel` sizes the viewport from the active pane).

- [ ] **Step 1: Add the section id**

In `core/enums/DashSection.qml`:

```qml
    readonly property string prayers: "prayers"
```

In `modules/dashboard/DashState.qml`, line 12:

```qml
    readonly property var sections: [DashSection.dash, DashSection.prayers, DashSection.performance, DashSection.media]
```

Prayers sits second so it is one keypress from the default tab. Moving it is a one-line edit to this array and the `tabs` array in the next step; the two orders must stay identical or the panes render under the wrong tabs.

- [ ] **Step 2: Create `modules/dashboard/prayers/PrayerRow.qml`**

```qml
import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    required property var entry
    required property bool active
    required property bool elapsed
    required property bool marker

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.prayer.rowHeight

    spacing: Appearance.dash.cardSpacing

    StyledText {
        Layout.fillWidth: true

        text: root.entry.label
        color: root.active ? Colours.textBright : root.elapsed || root.marker ? Colours.textMuted : Colours.text
        font.weight: root.active ? Appearance.font.weightActive : Appearance.font.weightNormal
        font.pixelSize: root.marker ? Appearance.dash.cardLabelSize : Appearance.font.size.normal
        elide: Text.ElideRight
    }

    StyledText {
        text: root.entry.time
        color: root.active ? Colours.accent : root.elapsed || root.marker ? Colours.textMuted : Colours.text
        font.weight: root.active ? Appearance.font.weightActive : Appearance.font.weightNormal
        font.pixelSize: root.marker ? Appearance.dash.cardLabelSize : Appearance.font.size.normal
    }
}
```

- [ ] **Step 3: Create `modules/dashboard/prayers/PrayerListCard.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.clock
            label: Appearance.prayer.labelToday
        }

        Repeater {
            model: Prayer.today

            PrayerRow {
                id: row

                required property var modelData

                entry: row.modelData
                marker: row.modelData.name === PrayerName.sunrise
                active: !!Prayer.current && !!row.modelData.date && Prayer.current.name === row.modelData.name && Prayer.current.date.getTime() === row.modelData.date.getTime()
                elapsed: !!row.modelData.date && row.modelData.date < Time.now && !row.active
            }
        }
    }
}
```

- [ ] **Step 4: Create `modules/dashboard/prayers/PrayerPane.qml`**

For now only the list column exists; the other two columns land in Tasks 7-9.

```qml
import QtQuick
import QtQuick.Layouts
import qs.core.config

RowLayout {
    id: root

    spacing: Appearance.dash.spacing

    ColumnLayout {
        Layout.preferredWidth: Appearance.prayer.listWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        PrayerListCard {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
```

- [ ] **Step 5: Wire the tab into `modules/dashboard/DashboardPanel.qml`**

Add the import:

```qml
import qs.modules.dashboard.prayers
```

Add the tab to the `tabs` array, **second**, matching `DashState.sections`:

```qml
            {
                section: DashSection.prayers,
                icon: Icons.prayersTab,
                label: Appearance.dash.labelPrayers
            },
```

Add the delegate choice inside the `DelegateChooser`:

```qml
                    DelegateChoice {
                        roleValue: DashSection.prayers

                        delegate: PrayerPane {}
                    }
```

- [ ] **Step 6: Verify**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
qs ipc call dashboard open prayers
```

Expected: the load gate is clean, and the dashboard opens on a Prayers tab showing six rows with today's times, the current interval highlighted, Shurūq visually smaller and muted.

---

### Task 7: Next prayer card

**Files:**
- Create: `modules/dashboard/prayers/PrayerNextCard.qml`
- Modify: `modules/dashboard/prayers/PrayerPane.qml`

**Interfaces:**
- Consumes: `Prayer.next`, `Prayer.countdown`, `Prayer.progress`, `Prayer.urgent`, `GaugeArc`.
- Produces: nothing new.

- [ ] **Step 1: Create `modules/dashboard/prayers/PrayerNextCard.qml`**

```qml
import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.prayersTab
            label: Prayer.place.city
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Appearance.prayer.arcSize
            Layout.preferredHeight: Appearance.prayer.arcSize

            GaugeArc {
                anchors.fill: parent

                value: Prayer.progress
                startAngle: Appearance.prayer.arcStart
                span: Appearance.prayer.arcSpan
                strokeWidth: Appearance.prayer.arcSize * Appearance.prayer.arcThicknessRatio
                fgColour: Prayer.urgent ? Colours.critical : Colours.accent
            }

            ColumnLayout {
                anchors.centerIn: parent

                spacing: Appearance.spacing.none

                StyledText {
                    Layout.alignment: Qt.AlignHCenter

                    text: Prayer.next?.label ?? Appearance.prayer.placeholder
                    color: Colours.textMuted
                    font.pixelSize: Appearance.prayer.nextNameSize
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter

                    text: Prayer.next?.time ?? Appearance.prayer.placeholder
                    color: Colours.textBright
                    font.pixelSize: Appearance.prayer.nextTimeSize
                    font.weight: Appearance.font.weightActive
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter

                    text: Prayer.countdown
                    color: Prayer.urgent ? Colours.critical : Colours.accent
                    font.weight: Appearance.font.weightActive
                }
            }
        }
    }
}
```

- [ ] **Step 2: Add the column to `PrayerPane.qml`**

Insert as the **first** column, before the list column:

```qml
    ColumnLayout {
        Layout.preferredWidth: Appearance.prayer.nextWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        PrayerNextCard {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
```

- [ ] **Step 3: Verify**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
qs ipc call dashboard open prayers
```

Expected: a ring showing progress through the current interval, with the next prayer's name, time and countdown inside it. The countdown must agree with the highlighted row in the list.

---

### Task 8: Location card with city search

**Files:**
- Create: `modules/dashboard/prayers/PrayerPlaceCard.qml`
- Create: `modules/dashboard/prayers/PrayerSearchRow.qml`
- Modify: `modules/dashboard/prayers/PrayerPane.qml`

**Interfaces:**
- Consumes: `Prayer.place`, `Prayer.source`, `Prayer.zoneMismatch`, `Prayer.pin`, `Prayer.unpin`, `Prayer.pinned`, `Geo.*`.
- Produces: nothing new.

- [ ] **Step 1: Create `modules/dashboard/prayers/PrayerSearchRow.qml`**

```qml
import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property var place

    signal picked

    implicitHeight: Appearance.prayer.optionHeight

    color: "transparent"
    radius: Appearance.prayer.optionRounding

    StateLayer {
        radius: parent.radius

        onClicked: root.picked()
    }

    StyledText {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal

        text: root.place.country ? `${root.place.city}, ${root.place.country}` : root.place.city
        color: Colours.text
        elide: Text.ElideRight
    }
}
```

- [ ] **Step 2: Create `modules/dashboard/prayers/PrayerPlaceCard.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.place
            label: Appearance.prayer.labelPlace
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.dash.cardSpacing

            StyledText {
                Layout.fillWidth: true

                text: Prayer.place.country ? `${Prayer.place.city}, ${Prayer.place.country}` : Prayer.place.city
                color: Colours.textBright
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledText {
                text: Prayer.source
                color: Colours.textMuted
                font.pixelSize: Appearance.dash.cardLabelSize
            }
        }

        StyledText {
            Layout.fillWidth: true

            text: Appearance.prayer.coordFormat.arg(Prayer.place.lat.toFixed(Appearance.prayer.coordPrecision)).arg(Prayer.place.lon.toFixed(Appearance.prayer.coordPrecision))
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
        }

        StyledText {
            Layout.fillWidth: true

            visible: Prayer.zoneMismatch
            text: Appearance.prayer.zoneWarning.arg(Prayer.place.tz).arg(Qt.formatDateTime(Time.now, "t"))
            color: Colours.critical
            font.pixelSize: Appearance.dash.cardLabelSize
            wrapMode: Text.Wrap
        }

        StyledText {
            Layout.fillWidth: true

            visible: Geo.error.length > 0
            text: Geo.error
            color: Colours.critical
            font.pixelSize: Appearance.dash.cardLabelSize
            wrapMode: Text.Wrap
        }

        TextField {
            id: search

            Layout.fillWidth: true

            icon: Icons.launcherSearch
            placeholder: Appearance.prayer.labelSearch

            onEdited: text => Geo.search(text)
        }

        StyledText {
            Layout.fillWidth: true

            visible: Geo.searching
            text: Appearance.prayer.labelSearching
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
        }

        Repeater {
            model: Geo.results

            PrayerSearchRow {
                id: result

                required property var modelData

                Layout.fillWidth: true

                place: result.modelData

                onPicked: {
                    Prayer.pin(result.modelData);
                    Geo.clearResults();
                    search.reset();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.dash.cardSpacing

            IconButton {
                icon: Icons.refresh
                disabled: Geo.detecting

                onTriggered: Geo.detect()
            }

            StyledText {
                Layout.fillWidth: true

                text: Geo.detecting ? Appearance.prayer.labelDetecting : Appearance.prayer.labelDetect
                color: Colours.textMuted
                font.pixelSize: Appearance.dash.cardLabelSize
                elide: Text.ElideRight
            }

            IconButton {
                icon: Icons.pinOff
                visible: !!Prayer.pinned

                onTriggered: Prayer.unpin()
            }
        }
    }
}
```

- [ ] **Step 3: Add the column to `PrayerPane.qml`**

As the third column:

```qml
    ColumnLayout {
        Layout.preferredWidth: Appearance.prayer.placeWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        PrayerPlaceCard {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
```

- [ ] **Step 4: Verify**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
qs ipc call dashboard open prayers
```

Expected: the card shows the detected place with a source chip and coordinates. Typing `Tiaret` produces a result list; clicking a result pins it, the chip changes to `Pinned`, the times recompute, and an unpin button appears. Clicking unpin returns to the detected place.

Verify persistence survives a restart:

```bash
cat "${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/prayer.json"
```

Expected: JSON with a non-null `pinned` after pinning, and `pinned: null` after unpinning.

---

### Task 9: Settings card

**Files:**
- Create: `modules/dashboard/prayers/PrayerSettingsCard.qml`
- Modify: `modules/dashboard/prayers/PrayerPane.qml`

**Interfaces:**
- Consumes: `Prayers.methods`, `Prayers.asrSchools`, `Prayers.highLatRules`, `Prayer.method`, `Prayer.asr`, `Prayer.highLat`, `Prayer.setMethod`, `Prayer.setAsr`, `Prayer.setHighLat`, `SegmentBar`.
- Produces: nothing new.

`SegmentBar` takes `options` as `[{ key, label }]` and emits `selected(key)`. Six methods will not fit in one bar at this column width, so the method list is a vertical `Repeater`; Asr and high-latitude use `SegmentBar`.

- [ ] **Step 1: Create `modules/dashboard/prayers/PrayerSettingsCard.qml`**

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.clock
            label: Appearance.prayer.labelMethod
        }

        Repeater {
            model: Prayers.methods

            StyledRect {
                id: option

                required property var modelData

                readonly property bool active: Prayer.method === option.modelData.id

                Layout.fillWidth: true
                Layout.preferredHeight: Appearance.prayer.optionHeight

                color: option.active ? Colours.hover : "transparent"
                radius: Appearance.prayer.optionRounding

                StateLayer {
                    radius: parent.radius

                    onClicked: Prayer.setMethod(option.modelData.id)
                }

                StyledText {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Appearance.padding.normal
                    anchors.rightMargin: Appearance.padding.normal

                    text: option.modelData.label
                    color: option.active ? Colours.accent : Colours.text
                    font.weight: option.active ? Appearance.font.weightActive : Appearance.font.weightNormal
                    elide: Text.ElideRight
                }
            }
        }

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.shield
            label: Appearance.prayer.labelAsr
        }

        SegmentBar {
            Layout.fillWidth: true

            options: Prayers.asrSchools.map(entry => ({
                        key: entry.id,
                        label: entry.label
                    }))
            current: Prayer.asr

            onSelected: key => Prayer.setAsr(key)
        }

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.sunriseMarker
            label: Appearance.prayer.labelHighLat
        }

        SegmentBar {
            Layout.fillWidth: true

            options: Prayers.highLatRules.map(entry => ({
                        key: entry.id,
                        label: entry.label
                    }))
            current: Prayer.highLat

            onSelected: key => Prayer.setHighLat(key)
        }
    }
}
```

- [ ] **Step 2: Add it under the place card in `PrayerPane.qml`**

Replace the third column's trailing spacer `Item` with the settings card:

```qml
        PrayerSettingsCard {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
```

- [ ] **Step 3: Verify**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
qs ipc call dashboard open prayers
```

Expected: selecting `ISNA` visibly moves Fajr later and Isha earlier; selecting `Hanafi` moves Asr later by roughly an hour; both survive a shell restart. Selecting high-latitude `None` while the place is Tiaret changes nothing — Tiaret never triggers the rule, which is itself the correct result.

---

### Task 10: Bar pill

**Files:**
- Modify: `core/enums/BarEntry.qml`
- Create: `modules/bar/components/PrayerPill.qml`
- Modify: `modules/bar/BarSlot.qml`
- Modify: `core/config/Appearance.qml:200` (`entriesCentre`)

**Interfaces:**
- Consumes: `Prayer.next`, `Prayer.countdown`, `Prayer.urgent`, `DashState.show`, `DashState.barHover`.
- Produces: `BarEntry.prayers`.

- [ ] **Step 1: Add the entry id**

In `core/enums/BarEntry.qml`:

```qml
    readonly property string prayers: "prayers"
```

- [ ] **Step 2: Create `modules/bar/components/PrayerPill.qml`**

```qml
import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.dashboard
import qs.services

Pill {
    id: root

    visible: !!Prayer.next
    interactive: true

    color: "transparent"

    onClicked: DashState.show(DashSection.prayers)

    HoverHandler {
        onHoveredChanged: DashState.barHover = hovered
    }

    Icon {
        text: Icons.prayersTab
        color: Prayer.urgent ? Colours.critical : Colours.textMuted
        font.pixelSize: Appearance.prayer.pillIconSize
    }

    StyledText {
        text: Prayer.next?.label ?? ""
        color: Prayer.urgent ? Colours.critical : Colours.text
        font.weight: Appearance.font.weightNormal
    }

    StyledText {
        text: Prayer.countdown
        color: Prayer.urgent ? Colours.critical : Colours.textMuted
        font.weight: Appearance.font.weightActive
    }
}
```

The `HoverHandler` writing `DashState.barHover` is **required, not decorative**. `WorldClock` is currently the only source of that property; without this the cursor moving from the clock onto the pill would report "not hovering" and close the dashboard mid-reach. See `docs/dashboard.md § Two hover sources, one state`.

- [ ] **Step 3: Register the delegate in `modules/bar/BarSlot.qml`**

```qml
            DelegateChoice {
                roleValue: BarEntry.prayers

                delegate: PrayerPill {}
            }
```

- [ ] **Step 4: Add a divider and the entry**

In `core/config/Appearance.qml` line 200:

```qml
        readonly property var entriesCentre: [BarEntry.worldClock, BarEntry.prayers]
```

`BarSlot`'s spacing is `Appearance.spacing.none`, so the two centre entries would otherwise touch. The separator belongs to the pill, not to `BarSlot` — `BarSlot` renders one delegate per entry and has nowhere to put a between-items rule without special-casing indices. So add it as the **first child of `PrayerPill.qml`**, above the existing `Icon`:

```qml
    StyledRect {
        implicitWidth: Appearance.prayer.dividerWidth
        implicitHeight: Appearance.prayer.dividerHeight

        color: Colours.textMuted
        opacity: Appearance.prayer.dividerOpacity
    }
```

`Pill`'s default property is the internal `RowLayout`, so this renders as the pill's first item — a vertical rule between the clock and the prayer text.

- [ ] **Step 5: Verify**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
```

Expected: clean load. Then restart the real shell and confirm:
- the pill sits to the right of the clock with a thin rule between them;
- it reads e.g. `Asr 1h23`;
- moving the cursor from the clock across the pill keeps the dashboard open (this is the regression the `HoverHandler` prevents);
- clicking it opens the dashboard on the Prayers tab.

---

### Task 11: Documentation and full verification pass

**Files:**
- Create: `docs/prayers.md`
- Modify: `probe.qml` (final sweep)

- [ ] **Step 1: Write `docs/prayers.md`**

Cover, in this order: what the feature is and its three layers; that times are computed locally and the network is only ever touched for geography; the elevation decision and **why** (with the 18:12 vs 18:05 measurement); the timezone decision and why the mismatch warning exists rather than silent correction; the reference table from the spec and how to re-run `check_prayer.qml`; the alert offsets and the critical-urgency behaviour; **the observed result of the `replaces_id` test from Task 5 Step 5**; and the fact that `Qt.exit()` / `Quickshell.quit()` do not work so headless checks must use `timeout` plus a grepped marker.

- [ ] **Step 2: Re-run the numeric gate**

```bash
timeout 20 qs -p check_prayer.qml 2>&1 | grep PRAYER-CHECK
```

Expected: `PRAYER-CHECK PASS worst=1min cases=6 failures=0`

- [ ] **Step 3: Re-run the load gate**

```bash
timeout 25 qs -p probe.qml 2>&1 | grep -iE "error|warn|Configuration Loaded" | grep -v "qt.qpa.services"
```

Expected: `Configuration Loaded`, nothing else.

- [ ] **Step 4: Confirm the glyphs render**

Restart the shell, open the Prayers tab, and take a screenshot:

```bash
grim -g "$(slurp)" /tmp/prayers.png
```

Inspect it. All five new glyphs must be actual icons, not tofu boxes (`􏿽`) and not the wrong symbol. `Icons.place` in particular was derived from a guessed codepoint; if it renders wrong, regenerate it with the python snippet in Task 2 Step 4 using a different Material Design codepoint.

- [ ] **Step 5: Confirm no comments were introduced**

```bash
grep -rn "^\s*//" core/helpers/Solar.qml core/constants/Prayers.qml core/enums/PrayerName.qml services/Prayer.qml services/Geo.qml services/PrayerAlerts.qml modules/dashboard/prayers/ modules/bar/components/PrayerPill.qml
```

Expected: no output. This repo removed 3,148 comment lines across 435 files in one sweep; a new one is a regression.

- [ ] **Step 6: Confirm the temporary alert trigger was removed**

```bash
grep -n "enqueue" services/PrayerAlerts.qml
```

Expected: only the `function enqueue` definition and the single call inside `scan()`. If a `Component.onCompleted` call from Task 5 Step 6 is still present, remove it.
