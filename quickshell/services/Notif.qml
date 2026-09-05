pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.core.config
import qs.core.helpers

QtObject {
    id: root

    required property Notification notification

    property string resolvedImage
    property string summary
    property string body
    property string iconSource
    property double created
    property bool held
    property bool shown
    property bool closing

    readonly property int urgency: notification?.urgency ?? NotificationUrgency.Normal
    readonly property bool critical: urgency === NotificationUrgency.Critical
    readonly property bool low: urgency === NotificationUrgency.Low
    readonly property int defaultTimeout: critical ? Appearance.notif.timeoutCritical : low ? Appearance.notif.timeoutLow : Appearance.notif.timeoutNormal
    readonly property int timeout: !notification || notification.expireTimeout < 0 ? defaultTimeout : notification.expireTimeout

    readonly property var actions: notification && !closing ? notification.actions : []
    readonly property var buttons: root.actions.filter(action => action.identifier !== "default")
    readonly property NotificationAction defaultAction: root.actions.find(action => action.identifier === "default") ?? null

    signal removed

    function refresh(): void {
        const source = root.notification;

        if (!source)
            return;

        root.summary = source.summary;
        root.body = source.body;
        root.iconSource = root.resolveSource(source);
    }

    function resolveSource(source: Notification): string {
        if (root.resolvedImage)
            return root.resolvedImage;

        if (source.image)
            return source.image;

        if (source.appIcon)
            return Fmt.icon(source.appIcon);

        const entry = source.desktopEntry ? DesktopEntries.heuristicLookup(source.desktopEntry) : source.appName ? DesktopEntries.heuristicLookup(source.appName) : null;
        return entry?.icon ? Fmt.icon(entry.icon) : "";
    }

    function resolveFavicon(): void {
        const source = root.notification;

        if (!source || root.resolvedImage)
            return;

        const app = `${source.desktopEntry} ${source.appName}`.toLowerCase();
        if (!Appearance.notif.faviconBrowsers.some(browser => app.includes(browser)))
            return;

        const host = Fmt.domain(source.body);
        if (!host)
            return;

        const cached = Notifs.favicons[host];
        if (cached) {
            root.adopt(cached);
            return;
        }

        favicon.host = host;
        favicon.target = `${Notifs.faviconDir}/${host}.ico`;
        favicon.command = ["curl", "-sfL", "--create-dirs", "--max-time", `${Appearance.notif.faviconTimeout}`, "-o", favicon.target, `${Appearance.notif.faviconEndpoint}/${host}.ico`];
        favicon.running = true;
    }

    function adopt(image: string): void {
        root.resolvedImage = image;
        root.refresh();
    }

    function arm(): void {
        expiry.stop();

        if (root.held || root.closing || !root.shown || root.timeout <= 0)
            return;

        expiry.interval = root.timeout;
        expiry.start();
    }

    function hold(value: bool): void {
        root.held = value;
        root.arm();
    }

    function close(): void {
        if (root.closing)
            return;

        root.closing = true;
        root.shown = false;
        expiry.stop();
        exit.start();
    }

    function invoke(action: NotificationAction): void {
        action.invoke();

        if (!root.notification.resident)
            root.notification.dismiss();
    }

    readonly property Connections updates: Connections {
        target: root.notification

        function onSummaryChanged(): void {
            root.refresh();
            root.arm();
        }

        function onBodyChanged(): void {
            root.refresh();
            root.arm();
        }

        function onClosed(): void {
            root.close();
        }
    }

    readonly property Process favicon: Process {
        property string host
        property string target

        onExited: code => {
            if (code !== 0)
                return;

            const image = `file://${favicon.target}`;
            Notifs.favicons[favicon.host] = image;
            root.adopt(image);
        }
    }

    readonly property Timer expiry: Timer {
        onTriggered: root.notification?.expire()
    }

    readonly property Timer exit: Timer {
        interval: Appearance.anim.durations.normal
        onTriggered: root.removed()
    }

    Component.onCompleted: {
        root.created = Date.now();
        root.refresh();
        root.resolveFavicon();
    }
}
