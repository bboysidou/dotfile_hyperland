pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string top: "top"
    readonly property string bottom: "bottom"
    readonly property string left: "left"
    readonly property string right: "right"

    readonly property var values: [root.top, root.bottom, root.left, root.right]

    readonly property var labels: ({
            top: "Top",
            bottom: "Bottom",
            left: "Left",
            right: "Right"
        })

    function vertical(edge: string): bool {
        return edge === root.left || edge === root.right;
    }
}
