pragma Singleton

import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property bool active: false
    property var supplies: []

    readonly property var source: root.supplies.filter(supply => Number(supply.online ?? 0) > 0).sort((first, second) => second.watts - first.watts)[0] ?? null
    readonly property bool connected: root.source !== null
    readonly property string kind: root.source?.type ?? ""
    readonly property string usbType: Str.choices(root.source?.usb_type ?? "").current
    readonly property real volts: root.source?.volts ?? 0
    readonly property real amps: root.source?.amps ?? 0
    readonly property real watts: root.source?.watts ?? 0

    function micro(raw): real {
        const value = Number(raw ?? 0);
        return isFinite(value) ? value / Units.microPerUnit : 0;
    }

    function supply(line: string): var {
        const fields = line.split("\t");
        const entry = {
            name: fields[0]
        };

        for (const field of fields.slice(1)) {
            const split = field.indexOf("=");
            if (split > 0)
                entry[field.slice(0, split)] = field.slice(split + 1).trim();
        }

        entry.volts = root.micro(entry.voltage_now) || root.micro(entry.voltage_max);
        entry.amps = Math.abs(root.micro(entry.current_now)) || root.micro(entry.current_max);
        entry.watts = entry.volts * entry.amps;
        return entry;
    }

    function adopt(text: string): void {
        root.supplies = text.split("\n").filter(line => line.trim() !== "").map(line => root.supply(line));
    }

    Poller {
        command: ["sh", "-c", Commands.chargerInfo, "sh", Paths.powerSupply]
        interval: Appearance.batteryTab.chargerInterval
        polling: root.active

        onReceived: text => root.adopt(text)
    }
}
