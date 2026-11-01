pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property list<Notif> popups: []
    property var favicons: ({})
    property int missedWhileLocked: 0
    property Notif replyTarget: null
    property var recent: []
    property string copied: ""

    readonly property string faviconDir: `${Paths.cache}/${Appearance.notif.faviconCacheDir}`

    readonly property var stack: root.toArray().slice(0, Prefs.maxPopups)
    readonly property var criticals: root.toArray().filter(popup => popup.critical).slice(0, Prefs.maxPopups)

    function track(notification: Notification): void {
        notification.tracked = true;

        if (Lock.locked)
            root.missedWhileLocked += 1;

        const existing = root.find(notification);
        if (existing) {
            existing.arm();
            return;
        }

        NotifHistory.remember(notification);

        const wrapper = component.createObject(root, {
            notification
        });

        wrapper.removed.connect(() => root.forget(wrapper));

        root.supersede(wrapper);
        root.popups = [wrapper].concat(root.toArray());
        root.restack();
    }

    function supersede(wrapper: Notif): void {
        if (wrapper.tag === "")
            return;

        for (const popup of root.toArray())
            if (popup.tag === wrapper.tag && popup.notification?.appName === wrapper.notification.appName)
                popup.notification.expire();
    }

    function latest(): Notif {
        return root.toArray().find(popup => !popup.closing) ?? null;
    }

    function focusApp(desktopEntry: string, appName: string): bool {
        const wanted = [desktopEntry, appName].map(name => Str.fold(name)).filter(name => name !== "");
        const match = Hyprland.toplevels.values.find(toplevel => {
            const app = Str.fold(toplevel.wayland?.appId ?? "");
            return app !== "" && wanted.some(name => app === name || app.endsWith(`.${name}`) || name.endsWith(`.${app}`));
        });

        if (!match)
            return false;

        Hyprland.dispatch(Hyprland.usingLua ? Appearance.notif.focusLua.arg(match.address) : Appearance.notif.focusLegacy.arg(match.address));
        return true;
    }

    function activate(popup: Notif): void {
        const source = popup?.notification;
        if (!source)
            return;

        if (popup.defaultAction) {
            popup.invoke(popup.defaultAction);
            return;
        }

        root.focusApp(source.desktopEntry, source.appName);
        source.dismiss();
    }

    function activateEntry(entry: NotifEntry): void {
        if (entry.defaultAction) {
            entry.defaultAction.invoke();
            return;
        }

        root.focusApp(entry.desktopEntry, entry.appName);
    }

    function dismissLatest(): void {
        root.latest()?.notification?.dismiss();
    }

    function openLatest(): void {
        root.activate(root.latest());
    }

    function record(snapshot: var): void {
        root.recent = [snapshot].concat(root.recent).slice(0, Appearance.notif.recentLimit);
    }

    function restore(): bool {
        const last = root.recent[0];
        if (!last)
            return false;

        root.recent = root.recent.slice(1);
        const icon = last.image.startsWith("/") || last.image.startsWith("file://") ? ["-i", last.image.replace("file://", "")] : [];
        Quickshell.execDetached(["notify-send", "-a", last.appName, "-u", NotifHints.urgencyNames[last.urgency] ?? NotifHints.urgencyNames[1], "-h", Appearance.notif.restoredFlag].concat(icon, [Commands.endOfOptions, last.summary, last.body]));
        return true;
    }

    function copy(text: string): void {
        Quickshell.execDetached(["wl-copy", "--", text]);
        root.copied = text;
        copiedTimer.restart();
    }

    readonly property Timer copiedTimer: Timer {
        interval: Appearance.notif.copiedTimeout

        onTriggered: root.copied = ""
    }

    function find(notification: Notification): Notif {
        return root.toArray().find(popup => popup.notification === notification) ?? null;
    }

    function forget(wrapper: Notif): void {
        NotifHistory.detach(wrapper.notification);
        root.popups = root.toArray().filter(popup => popup !== wrapper);
        root.restack();
        wrapper.destroy();
    }

    function restack(): void {
        const visible = root.stack;

        for (const popup of root.toArray()) {
            const shown = !popup.closing && visible.includes(popup);

            if (popup.shown !== shown) {
                popup.shown = shown;
                popup.arm();
            }
        }
    }

    function dismissAll(): void {
        for (const popup of root.toArray())
            popup.notification?.dismiss();
    }

    function toArray(): var {
        const out = [];

        for (let i = 0; i < root.popups.length; i++)
            out.push(root.popups[i]);

        return out;
    }

    readonly property Component component: Component {
        Notif {}
    }

    Connections {
        target: Lock

        function onLockedChanged(): void {
            if (!Lock.locked)
                root.missedWhileLocked = 0;
        }
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        bodyImagesSupported: false
        bodyHyperlinksSupported: false
        inlineReplySupported: true
        persistenceSupported: false
        extraHints: NotifHints.captured

        onNotification: notification => {
            root.track(notification);
            NotifSound.play();
        }
    }

    Component.onCompleted: {
        const tracked = server.trackedNotifications.values;

        for (let i = 0; i < tracked.length; i++)
            root.track(tracked[i]);
    }
}
