pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string standard: "standard"
    readonly property string pointy: "pointy"
    readonly property string double: "double"

    readonly property var values: [root.standard, root.pointy, root.double]
}
