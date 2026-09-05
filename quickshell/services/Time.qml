pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.components
import qs.core.config
import qs.core.constants

Singleton {
    id: root

    readonly property date now: clock.date
    readonly property string barText: Qt.formatDateTime(clock.date, Appearance.bar.clockFormat)

    property var zoneOffsets: ({})

    readonly property var zones: Appearance.dash.clockZones.map(entry => {
        const offset = root.zoneOffsets[entry.zone];
        const known = offset !== undefined;

        return {
            label: entry.label,
            zone: entry.zone,
            known: known,
            time: known ? Qt.formatDateTime(root.shifted(offset), Appearance.dash.clockTimeFormat) : Appearance.dash.clockPlaceholder,
            dayShift: known ? root.dayShift(offset) : 0
        };
    })

    function localOffset(): int {
        return -root.now.getTimezoneOffset();
    }

    function shifted(offset: int): date {
        return new Date(root.now.getTime() + (offset - root.localOffset()) * Units.msPerMinute);
    }

    function dayShift(offset: int): int {
        const here = root.now;
        const there = root.shifted(offset);
        const hereDay = new Date(here.getFullYear(), here.getMonth(), here.getDate()).getTime();
        const thereDay = new Date(there.getFullYear(), there.getMonth(), there.getDate()).getTime();

        return Math.round((thereDay - hereDay) / Units.msPerDay);
    }

    function applyOffsets(payload: string): void {
        const lines = payload.trim().split("\n").filter(line => line.length > 0);
        const configured = Appearance.dash.clockZones;

        if (lines.length !== configured.length)
            return;

        const next = {};

        for (let i = 0; i < configured.length; i++) {
            const match = /^([+-])(\d{2})(\d{2})$/.exec(lines[i].trim());
            if (!match)
                continue;

            const sign = match[1] === "-" ? -1 : 1;
            next[configured[i].zone] = sign * (Number(match[2]) * 60 + Number(match[3]));
        }

        root.zoneOffsets = next;
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Poller {
        command: ["sh", "-c", 'for z in "$@"; do TZ="$z" date +%z; done', "sh"].concat(Appearance.dash.clockZones.map(entry => entry.zone))
        interval: Appearance.dash.clockRefreshInterval

        onReceived: text => root.applyOffsets(text)
    }
}
