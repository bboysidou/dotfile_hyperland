pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.notif.historyFile}`

    property list<NotifEntry> entries: []
    property int counter: 0
    property bool loaded: false
    property bool viewing: false

    readonly property int unread: root.toArray().filter(entry => !entry.read).length

    readonly property var groups: {
        const buckets = new Map();

        for (const entry of root.toArray()) {
            const existing = buckets.get(entry.appName);

            if (existing)
                existing.entries.push(entry);
            else
                buckets.set(entry.appName, {
                    appName: entry.appName,
                    desktopEntry: entry.desktopEntry,
                    image: entry.image,
                    latest: entry.time,
                    entries: [entry]
                });
        }

        return Array.from(buckets.values()).sort((first, second) => second.latest - first.latest);
    }

    function toArray(): var {
        const out = [];

        for (let i = 0; i < root.entries.length; i++)
            out.push(root.entries[i]);

        return out;
    }

    function remember(notification): void {
        root.counter += 1;

        const entry = component.createObject(root, {
            key: `${Date.now()}-${root.counter}`,
            appName: notification.appName || Appearance.notif.labelUnknownApp,
            desktopEntry: notification.desktopEntry ?? "",
            summary: notification.summary ?? "",
            body: notification.body ?? "",
            image: root.resolve(notification),
            urgency: notification.urgency,
            time: Date.now(),
            read: root.viewing,
            notification
        });

        root.entries = [entry].concat(root.toArray());
        root.sweep();
        root.save();
    }

    function resolve(notification): string {
        if (notification.image)
            return notification.image;

        if (notification.appIcon)
            return Fmt.icon(notification.appIcon);

        const lookup = notification.desktopEntry || notification.appName;
        const entry = lookup ? DesktopEntries.heuristicLookup(lookup) : null;
        return entry?.icon ? Fmt.icon(entry.icon) : "";
    }

    function detach(notification): void {
        for (const entry of root.toArray())
            if (entry.notification === notification)
                entry.notification = null;
    }

    function dismiss(entry: NotifEntry): void {
        entry.notification?.dismiss();
        root.drop(list => list.filter(candidate => candidate !== entry));
    }

    function clearApp(appName: string): void {
        root.drop(list => list.filter(entry => entry.appName !== appName));
    }

    function clear(): void {
        root.loaded = true;
        root.drop(() => []);
    }

    function drop(transform): void {
        const kept = transform(root.toArray());
        const removed = root.toArray().filter(entry => !kept.includes(entry));

        root.entries = kept;
        root.flush();
        root.reap(removed);
    }

    function reap(removed: var): void {
        Qt.callLater(() => {
            for (const entry of removed)
                entry.destroy();
        });
    }

    function markAllRead(): void {
        let changed = false;

        for (const entry of root.toArray())
            if (!entry.read) {
                entry.read = true;
                changed = true;
            }

        if (changed)
            root.save();
    }

    function sweep(): void {
        const oldest = Date.now() - Appearance.notif.historyMaxAgeDays * Units.msPerDay;
        const fresh = root.toArray().filter(entry => entry.time >= oldest);
        const capped = fresh.slice(0, Appearance.notif.historyMaxEntries);

        if (capped.length === root.entries.length)
            return;

        const removed = root.toArray().filter(entry => !capped.includes(entry));

        root.entries = capped;
        root.reap(removed);
    }

    function save(): void {
        debounce.restart();
    }

    function flush(): void {
        if (!root.loaded) {
            root.save();
            return;
        }

        debounce.stop();
        store.setText(JSON.stringify({
            version: Appearance.notif.historyVersion,
            entries: root.toArray().map(entry => entry.serialise())
        }));
    }

    function adopt(payload: string): void {
        root.loaded = true;

        let parsed;

        try {
            parsed = JSON.parse(payload);
        } catch (e) {
            console.warn("NotifHistory: store is not valid JSON, starting empty");
            return;
        }

        if (!parsed || parsed.version !== Appearance.notif.historyVersion || !Array.isArray(parsed.entries))
            return;

        const restored = parsed.entries.map(raw => component.createObject(root, raw));
        root.entries = root.toArray().concat(restored);
        root.sweep();
    }

    readonly property Component component: Component {
        NotifEntry {}
    }

    readonly property Timer debounce: Timer {
        interval: Appearance.notif.historySaveDebounce

        onTriggered: root.flush()
    }

    readonly property Timer sweeper: Timer {
        interval: Appearance.notif.historySweepInterval
        running: true
        repeat: true

        onTriggered: root.sweep()
    }

    readonly property Process ensureDir: Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    readonly property FileView store: FileView {
        path: root.statePath
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
        onLoadFailed: root.loaded = true
    }
}
