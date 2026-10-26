pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string ms: "ms"
    readonly property string kmh: "kmh"
    readonly property string mph: "mph"

    readonly property var values: [root.ms, root.kmh, root.mph]

    readonly property var factors: ({
            ms: 1,
            kmh: 3.6,
            mph: 2.23694
        })

    readonly property var labels: ({
            ms: "m/s",
            kmh: "km/h",
            mph: "mph"
        })
}
