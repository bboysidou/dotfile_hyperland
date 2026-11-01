pragma Singleton

import Quickshell

Singleton {
    readonly property var line: /^(\d{4}-\d\d-\d\d) (\d\d:\d\d:\d\d)\.\d+\s+([A-Z]+)(?: ([^:\s]+))?: (.*)$/
    readonly property var qmlLocation: /^(?:file:\/\/)?(\S+?\.qml):(-?\d+)(?::-?\d+)?:\s*(.*)$/
    readonly property var continuation: /^\s/
    readonly property var address: /0x[0-9a-f]+/gi
    readonly property string timeSeparator: "T"
    readonly property string fieldSeparator: "\t"
    readonly property string locationTemplate: "%1:%2"
}
