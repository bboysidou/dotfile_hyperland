pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string network: "network"
    readonly property string bluetooth: "bluetooth"
    readonly property string audio: "audio"

    readonly property var values: [root.audio, root.network, root.bluetooth]
}
