pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property int dayMs: 86400000
    readonly property int countScanLimit: 3660
    readonly property var weekdays: ({
            SU: 0,
            MO: 1,
            TU: 2,
            WE: 3,
            TH: 4,
            FR: 5,
            SA: 6
        })

    function unfold(text: string): var {
        const lines = [];
        for (const raw of text.split(/\r?\n/)) {
            if ((raw.startsWith(" ") || raw.startsWith("\t")) && lines.length)
                lines[lines.length - 1] += raw.slice(1);
            else
                lines.push(raw);
        }
        return lines;
    }

    function decode(value: string): string {
        return value.replace(/\\n/gi, " ").replace(/\\([,;\\])/g, "$1");
    }

    function parseDate(value: string, params: string): var {
        const match = /^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})(Z)?)?$/.exec(value.trim());
        if (!match)
            return null;

        const [y, mo, d, h, mi, s, z] = [Number(match[1]), Number(match[2]) - 1, Number(match[3]), match[4], match[5], match[6], match[7]];
        if (h === undefined || params.includes("VALUE=DATE"))
            return {
                date: new Date(y, mo, d),
                allDay: true
            };
        const date = z ? new Date(Date.UTC(y, mo, d, Number(h), Number(mi), Number(s))) : new Date(y, mo, d, Number(h), Number(mi), Number(s));
        return {
            date: date,
            allDay: false
        };
    }

    function parseRule(value: string): var {
        const rule = {
            freq: "",
            interval: 1,
            byday: [],
            until: null,
            count: 0
        };
        for (const part of value.split(";")) {
            const [key, raw] = part.split("=");
            if (key === "FREQ")
                rule.freq = raw;
            else if (key === "INTERVAL")
                rule.interval = Math.max(1, Number(raw));
            else if (key === "COUNT")
                rule.count = Number(raw);
            else if (key === "UNTIL")
                rule.until = root.parseDate(raw, "")?.date ?? null;
            else if (key === "BYDAY")
                rule.byday = raw.split(",").map(day => root.weekdays[day.replace(/^[+-]?\d+/, "")]).filter(day => day !== undefined);
        }
        return rule;
    }

    function parse(text: string): var {
        const events = [];
        let current = null;
        for (const line of root.unfold(text)) {
            if (line === "BEGIN:VEVENT") {
                current = {
                    uid: "",
                    summary: "",
                    location: "",
                    start: null,
                    end: null,
                    allDay: false,
                    rule: null,
                    exdates: [],
                    recurrenceId: null,
                    cancelled: false
                };
                continue;
            }
            if (line === "END:VEVENT") {
                if (current?.start)
                    events.push(root.finish(current));
                current = null;
                continue;
            }
            if (!current)
                continue;

            const colon = line.indexOf(":");
            if (colon < 0)
                continue;
            const head = line.slice(0, colon);
            const value = line.slice(colon + 1);
            const name = head.split(";")[0];
            const params = head.slice(name.length);

            if (name === "UID")
                current.uid = value;
            else if (name === "SUMMARY")
                current.summary = root.decode(value);
            else if (name === "LOCATION")
                current.location = root.decode(value);
            else if (name === "STATUS")
                current.cancelled = value === "CANCELLED";
            else if (name === "RRULE")
                current.rule = root.parseRule(value);
            else if (name === "DTSTART") {
                const parsed = root.parseDate(value, params);
                current.start = parsed?.date ?? null;
                current.allDay = parsed?.allDay ?? false;
            } else if (name === "DTEND")
                current.end = root.parseDate(value, params)?.date ?? null;
            else if (name === "EXDATE")
                value.split(",").forEach(entry => {
                    const parsed = root.parseDate(entry, params);
                    if (parsed)
                        current.exdates.push(parsed.date.getTime());
                });
            else if (name === "RECURRENCE-ID")
                current.recurrenceId = root.parseDate(value, params)?.date.getTime() ?? null;
        }
        return events;
    }

    function finish(event): var {
        if (!event.end)
            event.end = new Date(event.start.getTime() + (event.allDay ? root.dayMs : 0));
        return event;
    }

    function dayNumber(date): int {
        return Math.floor(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()) / root.dayMs);
    }

    function matches(event, day): bool {
        const rule = event.rule;
        const diff = root.dayNumber(day) - root.dayNumber(event.start);
        if (diff < 0)
            return false;

        if (rule.freq === "DAILY")
            return diff % rule.interval === 0;
        if (rule.freq === "WEEKLY") {
            const days = rule.byday.length ? rule.byday : [event.start.getDay()];
            const monday = date => root.dayNumber(date) - (date.getDay() + 6) % 7;
            const weeks = Math.round((monday(day) - monday(event.start)) / 7);
            return days.includes(day.getDay()) && weeks % rule.interval === 0;
        }
        if (rule.freq === "MONTHLY") {
            const months = (day.getFullYear() - event.start.getFullYear()) * 12 + day.getMonth() - event.start.getMonth();
            return day.getDate() === event.start.getDate() && months % rule.interval === 0;
        }
        if (rule.freq === "YEARLY")
            return day.getMonth() === event.start.getMonth() && day.getDate() === event.start.getDate() && (day.getFullYear() - event.start.getFullYear()) % rule.interval === 0;
        return false;
    }

    function withinCount(event, day): bool {
        if (!event.rule.count)
            return true;

        let seen = 0;
        const target = root.dayNumber(day);
        for (let step = 0; step <= root.countScanLimit; step++) {
            const probe = new Date(event.start.getFullYear(), event.start.getMonth(), event.start.getDate() + step);
            if (root.matches(event, probe))
                seen += 1;
            if (root.dayNumber(probe) >= target)
                return seen <= event.rule.count;
            if (seen >= event.rule.count)
                return false;
        }
        return false;
    }

    function instance(event, day): var {
        const start = event.allDay ? new Date(day.getFullYear(), day.getMonth(), day.getDate()) : new Date(day.getFullYear(), day.getMonth(), day.getDate(), event.start.getHours(), event.start.getMinutes());
        return {
            summary: event.summary,
            location: event.location,
            allDay: event.allDay,
            start: start,
            end: new Date(start.getTime() + (event.end.getTime() - event.start.getTime()))
        };
    }

    function overlaps(event, day): bool {
        const dayStart = new Date(day.getFullYear(), day.getMonth(), day.getDate()).getTime();
        return event.start.getTime() < dayStart + root.dayMs && event.end.getTime() > dayStart;
    }

    function occurrences(events, day): var {
        const overrides = new Set(events.filter(event => event.recurrenceId !== null).map(event => `${event.uid}|${event.recurrenceId}`));
        const out = [];
        for (const event of events) {
            if (event.rule && event.recurrenceId === null) {
                if (!root.matches(event, day) || !root.withinCount(event, day))
                    continue;
                const occurrence = root.instance(event, day);
                const key = event.allDay ? new Date(day.getFullYear(), day.getMonth(), day.getDate()).getTime() : occurrence.start.getTime();
                if (event.rule.until && occurrence.start.getTime() > event.rule.until.getTime())
                    continue;
                if (event.exdates.includes(key) || overrides.has(`${event.uid}|${key}`))
                    continue;
                if (!event.cancelled)
                    out.push(occurrence);
            } else if (!event.cancelled && root.overlaps(event, day)) {
                out.push({
                    summary: event.summary,
                    location: event.location,
                    allDay: event.allDay,
                    start: event.start,
                    end: event.end
                });
            }
        }
        return out.sort((first, second) => first.start - second.start);
    }
}
