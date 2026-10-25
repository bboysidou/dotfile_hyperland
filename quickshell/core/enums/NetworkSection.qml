pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string networks: "networks"
    readonly property string speedTest: "speedtest"

    readonly property var values: [root.networks, root.speedTest]
}
