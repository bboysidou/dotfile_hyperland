pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.display

StyledRect {
    id: root

    readonly property var config: Appearance.display
    readonly property var boxes: DisplayState.names.filter(name => DisplayState.placed(name)).map(name => {
            const settings = DisplayState.drafts[name];
            const size = DisplayState.logical(settings);
            return {
                right: settings.x + size.width,
                bottom: settings.y + size.height
            };
        })
    readonly property real spanX: Math.max(1, ...root.boxes.map(box => box.right))
    readonly property real spanY: Math.max(1, ...root.boxes.map(box => box.bottom))
    readonly property real standSpace: DisplayState.bezels ? root.config.canvasStandHeight + root.config.canvasBaseHeight : 0
    readonly property real zoom: Math.min((root.width - root.config.canvasPadding * 2) / root.spanX, (root.height - root.config.canvasPadding * 2 - root.standSpace) / root.spanY)
    readonly property real originX: (root.width - root.spanX * root.zoom) / 2
    readonly property real originY: (root.height - root.standSpace - root.spanY * root.zoom) / 2

    function detail(name: string): string {
        const settings = DisplayState.drafts[name];
        if (settings.disabled)
            return root.config.labelDisabled;
        if (settings.mirror)
            return root.config.labelMirrored.arg(settings.mirror);
        return root.config.detailTemplate.arg(settings.width).arg(settings.height).arg(Number(settings.rate)).arg(settings.scale);
    }

    implicitHeight: root.config.canvasHeight

    radius: root.config.canvasRounding
    color: Colours.trough

    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: root.config.canvasToggleMargin

        z: 3
        spacing: root.config.canvasToggleSpacing

        Toggle {
            checked: DisplayState.bezels

            onToggled: checked => DisplayState.bezels = checked
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter

            text: root.config.labelBezels
            color: Colours.textMuted
        }
    }

    Repeater {
        model: DisplayState.names

        CanvasMonitor {
            required property string modelData

            name: modelData
            settings: DisplayState.drafts[modelData] ?? ({
                    x: 0,
                    y: 0,
                    width: 0,
                    height: 0,
                    scale: 1,
                    transform: 0,
                    disabled: true,
                    mirror: ""
                })
            zoom: root.zoom
            originX: root.originX
            originY: root.originY
            selected: modelData === DisplayState.monitor
            bezels: DisplayState.bezels
            detail: DisplayState.drafts[modelData] ? root.detail(modelData) : ""

            onPicked: DisplayState.monitor = modelData
            onDropped: (x, y) => DisplayState.place(modelData, x, y)
        }
    }
}
