pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string idle: "idle"
    readonly property string enrolling: "enrolling"
    readonly property string done: "done"
    readonly property string failed: "failed"
}
