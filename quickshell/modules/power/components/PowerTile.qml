import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums

Column {
    id: root

    required property string icon
    required property string label
    required property bool selected

    signal activated
    signal hovered

    spacing: Appearance.power.labelSpacing

    StyledRect {
        id: tile

        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: Appearance.power.tileSize
        implicitHeight: Appearance.power.tileSize

        color: root.selected ? Colours.hover : Colours.pill
        radius: Appearance.power.tileRounding
        border.width: root.selected ? Appearance.power.tileBorderWidth : 0
        border.color: Colours.accent
        scale: root.selected ? Appearance.power.selectedScale : 1

        Behavior on scale {
            Anim {
                type: AnimType.fastSpatial
            }
        }

        Icon {
            anchors.centerIn: parent

            text: root.icon
            color: root.selected ? Colours.accent : Colours.text
            font.pixelSize: Appearance.power.tileIconSize
        }

        StateLayer {
            onContainsMouseChanged: {
                if (containsMouse)
                    root.hovered();
            }
            onClicked: root.activated()
        }
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter

        text: root.label
        color: root.selected ? Colours.textBright : Colours.textMuted
        font.pixelSize: Appearance.power.labelSize
    }
}
