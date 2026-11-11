pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string left: "left"
    readonly property string centre: "centre"
    readonly property string right: "right"

    readonly property var values: [root.left, root.centre, root.right]

    readonly property var options: [
        {
            key: root.left,
            label: "Left"
        },
        {
            key: root.centre,
            label: "Centre"
        },
        {
            key: root.right,
            label: "Right"
        }
    ]
}
