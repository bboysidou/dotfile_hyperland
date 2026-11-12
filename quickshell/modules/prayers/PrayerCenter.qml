import QtQuick
import Quickshell
import Quickshell.Io
import qs.services as Services

Scope {
    id: root

    PrayerEngine { id: prayerEngine }
    PrayerAlerts { id: prayerAlerts; engine: prayerEngine }

    readonly property int pendingAlerts: prayerAlerts.queue.length

    Component.onCompleted: {
        Services.Prayer.backend = prayerEngine;
        Services.Prayer.alerts = prayerAlerts;
    }
    Component.onDestruction: {
        if (Services.Prayer.backend === prayerEngine)
            Services.Prayer.backend = null;
        if (Services.Prayer.alerts === prayerAlerts)
            Services.Prayer.alerts = null;
    }

    IpcHandler {
        target: "prayers"

        function status(): string {
            return `place=${Services.Prayer.place.city} source=${Services.Prayer.source} next=${Services.Prayer.next ? Services.Prayer.next.label : "none"} at=${Services.Prayer.next ? Services.Prayer.next.time : "--:--"} in=${Services.Prayer.countdown} queued=${root.pendingAlerts}`;
        }

        function times(): string {
            return Services.Prayer.today.map(entry => `${entry.label}=${entry.time}`).join(" ");
        }

        function detect(): string {
            Services.Geo.detect();
            return "detecting";
        }
    }
}
