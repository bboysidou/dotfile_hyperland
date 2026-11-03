pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string region: "region"
    readonly property string monitor: "monitor"
    readonly property string fullscreen: "fullscreen"
    readonly property string ocr: "ocr"

    readonly property var values: [root.region, root.monitor, root.fullscreen, root.ocr]
}
