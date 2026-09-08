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
