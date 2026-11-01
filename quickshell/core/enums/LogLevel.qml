pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string warn: "warn"
    readonly property string error: "error"
    readonly property string crash: "crash"
    readonly property string report: "report"

    readonly property var values: [root.warn, root.error, root.crash, root.report]

    readonly property var fromToken: ({
            WARN: root.warn,
            ERROR: root.error,
            CRIT: root.error,
            FATAL: root.crash
        })

    readonly property var labels: ({
            warn: "Warning",
            error: "Error",
            crash: "Crash",
            report: "Failure"
        })

    function isError(level: string): bool {
        return level !== root.warn;
    }
}
