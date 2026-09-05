pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property list<Notif> popups: []
    property var favicons: ({})
    property int missedWhileLocked: 0

    readonly property string faviconDir: `${Paths.cache}/${Appearance.notif.faviconCacheDir}`

    readonly property var stack: root.toArray().slice(0, Appearance.notif.maxVisible)

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

        root.popups = [wrapper].concat(root.toArray());
        root.restack();
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
        inlineReplySupported: false
        persistenceSupported: false

        onNotification: notification => root.track(notification)
    }

    Component.onCompleted: {
        const tracked = server.trackedNotifications.values;

        for (let i = 0; i < tracked.length; i++)
            root.track(tracked[i]);
    }
}
