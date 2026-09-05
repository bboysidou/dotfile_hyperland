import QtQuick
import qs.core.components
import qs.core.config

Item {
    id: root

    required property var panelWindow

    StyledRect {
        anchors.fill: parent

        color: Colours.bar
        radius: Appearance.rounding.large

        BarSlot {
            id: leftSlot

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Appearance.bar.paddingSide

            entries: Appearance.bar.entriesLeft
            panelWindow: root.panelWindow
            mediaBudget: centreSlot.x - leftSlot.x - Appearance.bar.mediaGapMin
        }

        BarSlot {
            id: centreSlot

            anchors.centerIn: parent

            entries: Appearance.bar.entriesCentre
            panelWindow: root.panelWindow
        }

        BarSlot {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Appearance.bar.paddingSide

            entries: Appearance.bar.entriesRight
            panelWindow: root.panelWindow
        }
    }
}
