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
