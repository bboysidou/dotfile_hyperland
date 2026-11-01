pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string extend: "extend"
    readonly property string mirror: "mirror"
    readonly property string only: "only"

    readonly property var values: [root.extend, root.mirror, root.only]
}
