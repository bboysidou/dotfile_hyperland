pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string supported: "supported"
    readonly property string unsupported: "unsupported"
    readonly property string unknown: "unknown"

    readonly property var values: [root.supported, root.unsupported, root.unknown]
}
