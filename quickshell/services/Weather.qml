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

    property bool active: false
    property var data: null
    property real fetchedAt: 0
    property bool loaded: false

    readonly property var config: Appearance.weather
    readonly property var place: Prayer.place
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property bool available: root.data !== null
    readonly property var dates: root.data?.daily?.time ?? []

    function refresh(): void {
        if (fetcher.running || !root.place)
            return;

        fetcher.command = Commands.fetch.concat([Commands.weatherUrl.arg(root.place.lat).arg(root.place.lon)]);
        fetcher.running = true;
    }

    function refreshIfStale(): void {
        const window = root.config.refreshMinutes * root.config.minuteMs * root.config.staleRatio;
        if (Date.now() - root.fetchedAt > window)
            root.refresh();
    }

    function receive(payload: string): void {
        try {
            const parsed = JSON.parse(payload);
            if (!parsed.current || !parsed.hourly || !parsed.daily)
                return;
            root.data = parsed;
            root.fetchedAt = Date.now();
            store.setText(JSON.stringify({
                fetchedAt: root.fetchedAt,
                data: root.data
            }));
        } catch (error) {
            return;
        }
    }

    function adopt(payload: string): void {
        try {
            const cached = JSON.parse(payload);
            root.data = cached.data ?? null;
            root.fetchedAt = cached.fetchedAt ?? 0;
        } catch (error) {
            root.data = null;
        }
        root.loaded = true;
        root.refreshIfStale();
    }

    function temp(celsius: real): real {
        return celsius * TempUnit.scales[Prefs.tempUnit] + TempUnit.offsets[Prefs.tempUnit];
    }

    function wind(metresPerSecond: real): real {
        return metresPerSecond * WindUnit.factors[Prefs.windUnit];
    }

    function kind(code: int): string {
        return root.config.codes[String(code)]?.[1] ?? "cloudy";
    }

    function describe(code: int): string {
        return root.config.codes[String(code)]?.[0] ?? "";
    }

    function glyph(code: int, day: bool): string {
        switch (root.kind(code)) {
        case "clear":
            return day ? Icons.weatherSunny : Icons.weatherNight;
        case "partly":
            return day ? Icons.weatherPartly : Icons.weatherNightPartly;
        case "fog":
            return Icons.weatherFog;
        case "drizzle":
            return Icons.weatherDrizzle;
        case "rain":
            return Icons.weatherRain;
        case "pouring":
            return Icons.weatherPouring;
        case "sleet":
            return Icons.weatherSleet;
        case "snow":
            return Icons.weatherSnow;
        case "heavySnow":
            return Icons.weatherHeavySnow;
        case "storm":
            return Icons.weatherStorm;
        case "hail":
            return Icons.weatherHail;
        default:
            return Icons.weatherCloudy;
        }
    }

    function hourlyIndexes(date: string): var {
        const times = root.data?.hourly?.time ?? [];
        const out = [];
        times.forEach((time, index) => {
            if (time.startsWith(date))
                out.push(index);
        });
        return out;
    }

    function average(values): real {
        return values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : 0;
    }

    function day(index: int): var {
        const daily = root.data?.daily;
        if (!daily || index < 0 || index >= daily.time.length)
            return null;

        if (index === 0) {
            const current = root.data.current;
            return {
                date: daily.time[0],
                code: current.weather_code,
                isDay: current.is_day === 1,
                temp: current.temperature_2m,
                feels: current.apparent_temperature,
                humidity: current.relative_humidity_2m,
                rain: current.precipitation_probability,
                wind: current.wind_speed_10m
            };
        }

        const hourly = root.data.hourly;
        const indexes = root.hourlyIndexes(daily.time[index]);
        return {
            date: daily.time[index],
            code: daily.weather_code[index],
            isDay: true,
            temp: daily.temperature_2m_max[index],
            feels: daily.apparent_temperature_max[index],
            humidity: Math.round(root.average(indexes.map(entry => hourly.relative_humidity_2m[entry]))),
            rain: daily.precipitation_probability_max[index],
            wind: daily.wind_speed_10m_max[index]
        };
    }

    function slots(index: int, nowHour: int): var {
        const date = root.dates[index];
        if (!date)
            return [];

        const hourly = root.data.hourly;
        const indexes = root.hourlyIndexes(date);
        const hours = root.config.slotHours;
        const passed = hours.filter(hour => hour <= nowHour);
        const current = index === 0 ? (passed.length ? passed[passed.length - 1] : hours[0]) : -1;

        return hours.map(hour => {
            const entry = indexes.find(candidate => Number(hourly.time[candidate].slice(11, 13)) === hour);
            return {
                hour: hour,
                active: hour === current,
                glyph: entry === undefined ? "" : root.glyph(hourly.weather_code[entry], hourly.is_day[entry] === 1),
                temp: entry === undefined ? NaN : hourly.temperature_2m[entry]
            };
        });
    }

    onPlaceChanged: {
        if (root.loaded)
            root.refresh();
    }

    Timer {
        interval: root.config.refreshMinutes * root.config.minuteMs
        running: root.active && root.loaded
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refreshIfStale()
    }

    Process {
        id: fetcher

        stdout: StdioCollector {
            onStreamFinished: root.receive(text)
        }
    }

    Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: store

        path: `${root.stateDir}/${root.config.stateFile}`
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
        onLoadFailed: root.adopt("{}")
    }
}
