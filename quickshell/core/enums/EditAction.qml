pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string fill: "fill"
    readonly property string backdrop: "backdrop"
    readonly property string undo: "undo"
    readonly property string redo: "redo"
    readonly property string pin: "pin"
    readonly property string ocr: "ocr"
    readonly property string copy: "copy"
    readonly property string save: "save"
    readonly property string close: "close"

    readonly property var labels: ({
            [root.fill]: "Fill",
            [root.backdrop]: "Backdrop",
            [root.undo]: "Undo",
            [root.redo]: "Redo",
            [root.pin]: "Pin",
            [root.ocr]: "OCR",
            [root.copy]: "Copy",
            [root.save]: "Save",
            [root.close]: "Close"
        })
    readonly property var hints: ({
            [root.fill]: "F",
            [root.backdrop]: "G",
            [root.undo]: "Ctrl+Z",
            [root.redo]: "Ctrl+Y",
            [root.pin]: "P",
            [root.ocr]: "O",
            [root.copy]: "Ctrl+C",
            [root.save]: "Enter",
            [root.close]: "Esc"
        })

    readonly property var values: [root.fill, root.backdrop, root.undo, root.redo, root.pin, root.ocr, root.copy, root.save, root.close]
}
