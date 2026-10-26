pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string system: "system"
    readonly property string user: "user"
    readonly property string flag: "flag"

    readonly property var values: [root.system, root.user, root.flag]
}
