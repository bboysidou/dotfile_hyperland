pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string tab: "tab"
    readonly property string grey: "grey"
    readonly property string off: "off"

    readonly property var values: [root.tab, root.grey, root.off]

    readonly property var labels: ({
            tab: "Tab",
            grey: "Grey",
            off: "Off"
        })
}
