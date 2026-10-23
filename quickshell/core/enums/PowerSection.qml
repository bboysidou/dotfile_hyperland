pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string overview: "overview"
    readonly property string history: "history"
    readonly property string details: "details"
    readonly property string care: "care"

    readonly property var values: [root.overview, root.history, root.details, root.care]
}
