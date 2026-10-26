pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string ns: "ns"
    readonly property string cycles: "cycles"
    readonly property string pct: "pct"

    readonly property var values: [root.ns, root.cycles, root.pct]
}
