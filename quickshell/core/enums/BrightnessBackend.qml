pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string none: "none"
    readonly property string backlight: "backlight"
    readonly property string ddc: "ddc"

    readonly property var values: [root.none, root.backlight, root.ddc]
}
