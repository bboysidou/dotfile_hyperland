pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    property string key
    property string appName
    property string desktopEntry
    property string summary
    property string body
    property string image
    property int urgency: NotificationUrgency.Normal
    property double time
    property bool read

    property Notification notification

    readonly property bool live: root.notification !== null
    readonly property bool critical: root.urgency === NotificationUrgency.Critical

    readonly property var actions: root.live ? root.notification.actions : []
    readonly property var buttons: root.actions.filter(action => action.identifier !== "default")
    readonly property NotificationAction defaultAction: root.actions.find(action => action.identifier === "default") ?? null

    function serialise(): var {
        return {
            key: root.key,
            appName: root.appName,
            desktopEntry: root.desktopEntry,
            summary: root.summary,
            body: root.body,
            image: root.image,
            urgency: root.urgency,
            time: root.time,
            read: root.read
        };
    }
}
