pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string overview: "overview"
    readonly property string battery: "battery"

    readonly property var values: [root.overview, root.battery]
}
