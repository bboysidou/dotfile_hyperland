import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.services

Scope {
    id: root

    required property var engine
    property bool stopping: false
    property var queue: []

    function sameMinute(a: date, b: date): bool {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate() && a.getHours() === b.getHours() && a.getMinutes() === b.getMinutes();
    }

    function scan(): void {
        if (root.stopping || !Prefs.prayersEnabled || !root.engine.ready)
            return;
        const now = Time.now;
        const dayKey = Qt.formatDateTime(now, Appearance.prayer.dayKeyFormat);
        const kept = {};

        for (const key in Prayer.firedAlerts)
            if (key.indexOf(`${dayKey}|`) === 0)
                kept[key] = true;

        for (const entry of root.engine.schedule) {
            if (!entry.alerting)
                continue;

            for (const offset of Appearance.prayer.alertOffsets) {
                const target = new Date(entry.date.getTime() - offset * Units.msPerMinute);

                if (!root.sameMinute(target, now))
                    continue;

                const key = `${dayKey}|${entry.name}|${offset}`;

                if (kept[key])
                    continue;

                kept[key] = true;
                root.enqueue(entry, offset);
            }
        }

        Prayer.firedAlerts = kept;
    }

    function supersede(entry: var): void {
        for (const popup of Notifs.toArray()) {
            const notification = popup.notification;

            if (!notification || notification.appName !== Appearance.prayer.notifyAppName)
                continue;

            if (notification.summary.indexOf(entry.label) === 0)
                notification.dismiss();
        }
    }

    function enqueue(entry: var, offset: int): void {
        if (root.stopping || !Prefs.prayersEnabled || !root.engine.ready)
            return;
        const index = PrayerName.alerting.indexOf(entry.name);

        root.supersede(entry);

        const summary = offset > 0 ? `${entry.label} in ${offset} minutes` : `${entry.label} — it's time`;
        const body = `${entry.time} · ${root.engine.place.city}`;

        root.queue = root.queue.concat([["notify-send", "-u", "critical", "-a", Appearance.prayer.notifyAppName, "-r", String(Appearance.prayer.notifyIdBase + index), summary, body]]);
        root.pump();
    }

    function pump(): void {
        if (root.stopping || !Prefs.prayersEnabled || notifier.running || root.queue.length === 0)
            return;

        notifier.command = root.queue[0];
        root.queue = root.queue.slice(1);
        notifier.running = true;
    }

    Process {
        id: notifier

        onExited: root.pump()
    }

    Connections {
        target: Time
        enabled: Prefs.prayersEnabled && root.engine.ready

        function onNowChanged(): void {
            root.scan();
        }
    }

    Connections {
        target: root.engine
        function onScheduleChanged(): void { root.scan(); }
    }

    Component.onCompleted: {
        console.info("[PrayerTimes] alerts started");
        root.scan();
    }
    Component.onDestruction: {
        root.stopping = true;
        root.queue = [];
        notifier.running = false;
        console.info("[PrayerTimes] alerts stopped");
    }
}
