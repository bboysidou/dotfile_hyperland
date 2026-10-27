pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string cpu: "cpu"
    readonly property string gpu: "gpu"

    readonly property var values: [root.cpu, root.gpu]
}
