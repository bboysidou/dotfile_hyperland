pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string celsius: "celsius"
    readonly property string fahrenheit: "fahrenheit"

    readonly property var values: [root.celsius, root.fahrenheit]

    readonly property var scales: ({
            celsius: 1,
            fahrenheit: 1.8
        })

    readonly property var offsets: ({
            celsius: 0,
            fahrenheit: 32
        })

    readonly property var labels: ({
            celsius: "°C",
            fahrenheit: "°F"
        })
}
