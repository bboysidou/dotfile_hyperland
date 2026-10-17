pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string cpu: "cpu"
    readonly property string gpu: "gpu"
    readonly property string memory: "memory"

    readonly property var values: [root.cpu, root.gpu, root.memory]
}
