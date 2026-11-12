pragma Singleton

import Quickshell

Singleton {
    readonly property var fired: Prayer.firedAlerts
    readonly property var queue: Prayer.alerts ? Prayer.alerts.queue : []

    function sameMinute(a: date, b: date): bool {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate() && a.getHours() === b.getHours() && a.getMinutes() === b.getMinutes();
    }
}
