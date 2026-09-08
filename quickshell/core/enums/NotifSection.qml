pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string all: "all"
    readonly property string unread: "unread"
    readonly property string critical: "critical"

    readonly property var values: [root.all, root.unread, root.critical]
}
