pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string edit: "edit"
    readonly property string pin: "pin"
    readonly property string copy: "copy"
    readonly property string folder: "folder"
    readonly property string trash: "trash"
    readonly property string close: "close"

    readonly property var labels: ({
            [root.edit]: "Edit",
            [root.pin]: "Pin",
            [root.copy]: "Copy",
            [root.folder]: "Folder",
            [root.trash]: "Trash",
            [root.close]: "Close"
        })

    readonly property var values: [root.edit, root.pin, root.copy, root.folder, root.trash, root.close]
}
