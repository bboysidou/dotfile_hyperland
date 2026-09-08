pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants

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
            debounce.stop();
            root.clearResults();
            return;
        }

        debounce.restart();
    }

    function clearResults(): void {
        root.results = [];
        root.searching = false;
    }

    function offsetFor(tz: string): real {
        const offset = root.zoneOffsets[tz];
        return offset === undefined ? NaN : offset;
    }

    function requestZone(tz: string): void {
        if (!tz || root.zoneOffsets[tz] !== undefined || zoneProbe.running)
            return;

        zoneProbe.pending = tz;
        zoneProbe.command = ["sh", "-c", 'TZ="$1" date +%z', "sh", tz];
        zoneProbe.running = true;
    }

    function applyDetection(payload: string): void {
        root.detecting = false;

        try {
            const data = JSON.parse(payload);

            if (data.success === false || typeof data.latitude !== "number" || typeof data.longitude !== "number") {
                root.error = data.message ?? "Location lookup failed";
                return;
            }

            root.detected = {
                lat: data.latitude,
                lon: data.longitude,
                city: data.city ?? "",
                country: data.country_code ?? "",
                tz: data.timezone?.id ?? ""
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
            finder.command = ["curl", "-sf", "--max-time", String(Appearance.prayer.requestTimeout), Prayers.searchEndpoint.arg(encodeURIComponent(root.pendingQuery)).arg(Appearance.prayer.searchMaxResults)];
            finder.running = true;
        }
    }

    Process {
        id: locator

        command: ["curl", "-sf", "--max-time", String(Appearance.prayer.requestTimeout), Prayers.geoEndpoint]

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
