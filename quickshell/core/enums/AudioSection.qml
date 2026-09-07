pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string outputs: "outputs"
    readonly property string inputs: "inputs"
    readonly property string streams: "streams"

    readonly property var values: [root.outputs, root.inputs, root.streams]
}
