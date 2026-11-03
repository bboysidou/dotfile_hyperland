pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string pixelate: "pixelate"
    readonly property string solid: "solid"

    readonly property var values: [root.pixelate, root.solid]
}
