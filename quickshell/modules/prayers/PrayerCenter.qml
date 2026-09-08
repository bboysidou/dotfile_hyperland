import Quickshell
import Quickshell.Io
import qs.services

Scope {
    id: root

    readonly property int pendingAlerts: PrayerAlerts.queue.length

    IpcHandler {
        target: "prayers"

        function status(): string {
            return `place=${Prayer.place.city} source=${Prayer.source} next=${Prayer.next ? Prayer.next.label : "none"} at=${Prayer.next ? Prayer.next.time : "--:--"} in=${Prayer.countdown} queued=${root.pendingAlerts}`;
        }

        function times(): string {
            return Prayer.today.map(entry => `${entry.label}=${entry.time}`).join(" ");
        }

        function detect(): string {
            Geo.detect();
            return "detecting";
        }
    }
}
