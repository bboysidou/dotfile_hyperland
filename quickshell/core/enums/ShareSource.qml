pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string screen: "screen"
    readonly property string window: "window"
    readonly property string workspace: "workspace"

    readonly property var values: [root.screen, root.window, root.workspace]
}
