pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string idle: "idle"
    readonly property string down: "down"
    readonly property string up: "up"
    readonly property string done: "done"

    readonly property var values: [root.idle, root.down, root.up, root.done]
}
