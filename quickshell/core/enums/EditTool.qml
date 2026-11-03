pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string select: "select"
    readonly property string arrow: "arrow"
    readonly property string line: "line"
    readonly property string rect: "rect"
    readonly property string ellipse: "ellipse"
    readonly property string marker: "marker"
    readonly property string text: "text"
    readonly property string highlight: "highlight"
    readonly property string redact: "redact"
    readonly property string crop: "crop"

    readonly property var labels: ({
            [root.select]: "Select",
            [root.arrow]: "Arrow",
            [root.line]: "Line",
            [root.rect]: "Box",
            [root.ellipse]: "Circle",
            [root.marker]: "Number",
            [root.text]: "Text",
            [root.highlight]: "Highlight",
            [root.redact]: "Redact",
            [root.crop]: "Crop"
        })
    readonly property var hints: ({
            [root.select]: "V",
            [root.arrow]: "A",
            [root.line]: "L",
            [root.rect]: "R",
            [root.ellipse]: "E",
            [root.marker]: "C",
            [root.text]: "T",
            [root.highlight]: "H",
            [root.redact]: "B",
            [root.crop]: "X"
        })

    readonly property var values: [root.select, root.arrow, root.line, root.rect, root.ellipse, root.marker, root.text, root.highlight, root.redact, root.crop]
}
