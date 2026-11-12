pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.barlayout

StyledRect {
    id: root

    property string zone: ""
    property string title: ""
    property var entries: []
    property string dragging: ""
    property bool targeted: false
    property string before: ""
    property real minHeight: Appearance.barLayout.zoneMinHeight

    readonly property var config: Appearance.barLayout
    readonly property Item marker: root.before !== "" ? chips.itemAt(root.entries.indexOf(root.before)) : chips.itemAt(root.entries.length - 1)

    signal chipPressed(Item chip, real x, real y)
    signal chipMoved(Item chip, real x, real y)
    signal chipReleased(Item chip, real x, real y)

    function beforeAt(point: point): string {
        for (let index = 0; index < root.entries.length; index++) {
            const chip = chips.itemAt(index);
            const local = flow.mapFromItem(root, point.x, point.y);
            if (!chip || root.entries[index] === root.dragging)
                continue;
            if (local.y < chip.y || (local.y < chip.y + chip.height && local.x < chip.x + chip.width / 2))
                return root.entries[index];
        }
        return "";
    }

    implicitHeight: Math.max(root.minHeight, flow.implicitHeight + heading.implicitHeight + root.config.labelSpacing + root.config.zonePadding * 2)

    radius: root.config.zoneRounding
    color: Colours.pill
    border.width: root.targeted ? root.config.chipBorder : 0
    border.color: Colours.accent

    StyledText {
        id: heading

        x: root.config.zonePadding
        y: root.config.zonePadding

        text: root.title
        color: Colours.textMuted
        font.pixelSize: root.config.chipTextSize
        font.bold: true
    }

    Flow {
        id: flow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: heading.bottom
        anchors.margins: root.config.zonePadding
        anchors.topMargin: root.config.labelSpacing

        spacing: root.config.chipSpacing

        move: Transition {
            Anim {
                properties: "x,y"
                type: AnimType.fastSpatial
            }
        }

        Repeater {
            id: chips

            model: root.entries

            LayoutChip {
                id: chip

                required property string modelData

                entry: chip.modelData
                dragged: root.dragging === chip.modelData

                onPressed: (x, y) => root.chipPressed(chip, x, y)
                onMoved: (x, y) => root.chipMoved(chip, x, y)
                onReleased: (x, y) => root.chipReleased(chip, x, y)
            }
        }
    }

    Rectangle {
        visible: root.targeted && root.zone !== "" && root.marker !== null
        x: flow.x + (root.marker?.x ?? 0) + (root.before !== "" ? -root.config.chipSpacing / 2 : (root.marker?.width ?? 0) + root.config.chipSpacing / 2) - width / 2
        y: flow.y + (root.marker?.y ?? 0)
        width: root.config.markerWidth
        height: root.config.chipHeight
        radius: width / 2
        color: Colours.accent
    }
}
