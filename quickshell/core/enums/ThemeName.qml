pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string defaultTheme: "default"
    readonly property string monochrome: "monochrome"
    readonly property string hacker: "hacker"

    readonly property var values: [root.defaultTheme, root.monochrome, root.hacker]
}
