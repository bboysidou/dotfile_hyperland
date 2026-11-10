pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.core.config
import qs.core.constants
import qs.core.helpers

QtObject {
    id: root

    required property Notification notification

    property NotifEntry entry: null
    property string resolvedImage
    property string summary
    property string body
    property string iconSource
    property string appSource
    property string origin
    property double created
    property bool held
    property bool shown
    property bool closing
    property double armedAt
    property int armedFor

    readonly property int urgency: notification?.urgency ?? NotificationUrgency.Normal
    readonly property bool critical: urgency === NotificationUrgency.Critical
    readonly property int defaultTimeout: Prefs.notifTimeouts[urgency] ?? Appearance.notif.timeoutNormal
    readonly property bool persistent: !!notification && root.value >= 0 && (notification.resident || notification.expireTimeout === 0)
    readonly property int timeout: !notification || notification.expireTimeout < 0 || root.persistent ? defaultTimeout : notification.expireTimeout
    property bool kept

    readonly property string preview: notification?.hints?.category === Appearance.notif.previewCategory ? Fmt.icon(notification.hints["image-path"] ?? "") : ""

    readonly property string browser: {
        const app = `${notification?.desktopEntry ?? ""} ${notification?.appName ?? ""}`.toLowerCase();
        return Appearance.notif.faviconBrowsers.find(name => app.includes(name)) ?? "";
    }
    readonly property string originBrowser: Appearance.notif.originBrowsers.find(name => root.browser.includes(name)) ?? ""
    readonly property string avatar: root.browser !== "" && notification?.image && !root.preview ? notification.image : ""
    readonly property string badge: root.avatar !== "" ? (root.resolvedImage || root.appSource) : ""
    property bool hadAvatar: false
    readonly property string historyImage: root.hadAvatar ? (root.resolvedImage || root.appSource) : root.iconSource
    readonly property var hints: notification?.hints ?? ({})
    readonly property string tag: NotifHistory.tagOf(root.hints)
    readonly property int value: NotifHistory.valueOf(root.hints)
    readonly property string code: Str.otp(`${root.summary} ${root.body}`)
    readonly property bool replyable: !!notification?.hasInlineReply && !closing
    property bool replying

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
        root.appSource = root.resolveApp(source);
        root.iconSource = root.resolveSource(source);
    }

    function resolveApp(source: Notification): string {
        if (source.appIcon)
            return Fmt.icon(source.appIcon);

        const entry = source.desktopEntry ? DesktopEntries.heuristicLookup(source.desktopEntry) : source.appName ? DesktopEntries.heuristicLookup(source.appName) : null;
        return entry?.icon ? Fmt.icon(entry.icon) : "";
    }

    function resolveSource(source: Notification): string {
        if (root.avatar)
            return root.avatar;

        if (root.resolvedImage)
            return root.resolvedImage;

        if (source.image && !root.preview)
            return source.image;

        return root.appSource;
    }

    function resolveFavicon(): void {
        const source = root.notification;

        if (!source || root.resolvedImage)
            return;

        if (root.browser === "")
            return;

        const host = Fmt.domain(source.body);
        if (host) {
            root.fetchFavicon(host);
            return;
        }

        if (root.originBrowser === "")
            return;

        originProbe.command = [`${Quickshell.shellDir}/${Appearance.notif.originScript}`, root.originBrowser, root.summary, Notifs.faviconDir];
        originProbe.running = true;
    }

    function fetchFavicon(host: string): void {
        root.origin = host;
        NotifHistory.setOrigin(root.entry, host);

        const cached = Notifs.favicons[host];
        if (cached) {
            root.adopt(cached);
            return;
        }

        favicon.host = host;
        favicon.target = `${Notifs.faviconDir}/${host}.ico`;
        const parent = host.split(".").slice(-2).join(".");
        favicon.command = ["sh", "-c", Commands.faviconFetch, "sh", favicon.target, `${Appearance.notif.faviconTimeout}`, `${Appearance.notif.faviconEndpoint}/${host}.ico`, `${Appearance.notif.faviconEndpoint}/${parent}.ico`];
        favicon.running = true;
    }

    function adopt(image: string): void {
        root.resolvedImage = image;
        root.refresh();
    }

    function arm(): void {
        expiry.stop();
        root.armedFor = 0;

        if (root.held || root.closing || !root.shown || root.timeout <= 0)
            return;

        expiry.interval = root.timeout;
        root.armedAt = Date.now();
        root.armedFor = root.timeout;
        expiry.start();
    }

    function retire(): void {
        root.kept = true;
        root.close();
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
    }

    function startReply(): void {
        root.replying = true;
        root.hold(true);
        Notifs.replyTarget = root;
    }

    function stopReply(): void {
        root.replying = false;
        root.hold(false);
        if (Notifs.replyTarget === root)
            Notifs.replyTarget = null;
    }

    function reply(text: string): void {
        const source = root.notification;
        root.stopReply();
        if (!source || text.trim() === "")
            return;
        source.sendInlineReply(text);
    }

    function snapshot(): var {
        const source = root.notification;
        return {
            appName: source?.appName ?? "",
            urgency: root.urgency,
            image: root.iconSource,
            summary: root.summary,
            body: Str.plain(root.body)
        };
    }

    readonly property Connections apps: Connections {
        target: Notifs

        function onAppCountChanged(): void {
            root.refresh();
        }
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

        function onClosed(reason: int): void {
            if (reason === NotificationCloseReason.Dismissed)
                Notifs.record(root.snapshot());
            root.stopReply();
            root.close();
        }
    }

    readonly property Process originProbe: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const [host, icon] = text.trim().split("\t");
                if (!host || !root.notification)
                    return;
                if (icon) {
                    root.origin = host;
                    NotifHistory.setOrigin(root.entry, host);
                    Notifs.favicons[host] = `file://${icon}`;
                }
                root.fetchFavicon(host);
            }
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
        onTriggered: root.persistent ? root.retire() : root.notification?.expire()
    }

    readonly property Timer exit: Timer {
        interval: Appearance.anim.durations.normal
        onTriggered: root.removed()
    }

    onHistoryImageChanged: NotifHistory.setImage(root.entry, root.historyImage, root.avatar)
    onAvatarChanged: {
        if (root.avatar !== "")
            root.hadAvatar = true;
        NotifHistory.setImage(root.entry, root.historyImage, root.avatar);
    }

    Component.onCompleted: {
        root.entry = NotifHistory.entryOf(root.notification);
        root.created = Date.now();
        root.hadAvatar = root.avatar !== "";
        root.refresh();
        NotifHistory.setImage(root.entry, root.historyImage, root.avatar);
        root.resolveFavicon();
    }
}
