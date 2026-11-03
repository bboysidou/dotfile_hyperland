pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string free: "free"
    readonly property string square: "square"
    readonly property string portrait: "portrait"
    readonly property string wide: "wide"

    readonly property var values: [root.free, root.square, root.portrait, root.wide]

    readonly property var ratios: ({
            free: 0,
            square: 1,
            portrait: 4 / 3,
            wide: 9 / 16
        })

    readonly property var labels: ({
            free: "Free",
            square: "1:1",
            portrait: "3:4",
            wide: "16:9"
        })
}
