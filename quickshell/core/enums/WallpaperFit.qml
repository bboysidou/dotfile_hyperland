pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string fill: "fill"
    readonly property string fit: "fit"
    readonly property string center: "center"
    readonly property string stretch: "stretch"
    readonly property string tile: "tile"
    readonly property string span: "span"

    readonly property var values: [root.fill, root.fit, root.center, root.stretch, root.tile, root.span]

    readonly property var fillModes: ({
            fill: Image.PreserveAspectCrop,
            fit: Image.PreserveAspectFit,
            center: Image.Pad,
            stretch: Image.Stretch,
            tile: Image.Tile,
            span: Image.PreserveAspectCrop
        })

    readonly property var keys: ({
            fill: Qt.Key_F,
            fit: Qt.Key_I,
            center: Qt.Key_C,
            stretch: Qt.Key_S,
            tile: Qt.Key_T,
            span: Qt.Key_W
        })

    readonly property var letters: ({
            fill: "F",
            fit: "I",
            center: "C",
            stretch: "S",
            tile: "T",
            span: "W"
        })

    readonly property var labels: ({
            fill: "Fill",
            fit: "Fit",
            center: "Center",
            stretch: "Stretch",
            tile: "Tile",
            span: "Span"
        })

    readonly property var unscaled: [root.center, root.tile]

    function fromKey(key: int): string {
        return root.values.find(value => root.keys[value] === key) ?? "";
    }
}
