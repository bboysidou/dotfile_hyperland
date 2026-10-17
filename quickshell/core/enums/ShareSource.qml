pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string screen: "screen"
    readonly property string window: "window"

    readonly property var values: [root.screen, root.window]
}
