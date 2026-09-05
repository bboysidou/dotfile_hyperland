pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string lock: "lock"
    readonly property string logout: "logout"
    readonly property string reboot: "reboot"
    readonly property string shutdown: "shutdown"

    readonly property var values: [root.lock, root.logout, root.reboot, root.shutdown]
}
