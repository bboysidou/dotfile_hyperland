pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property string placeholder
    required property var entries

    color: Colours.pill
    radius: Appearance.updates.sectionRounding

    UpdateGridHeader {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.updates.rowPaddingH
        anchors.rightMargin: Appearance.updates.rowPaddingH
        anchors.topMargin: Appearance.updates.sectionPaddingV

        visible: root.entries.length > 0
    }

    StyledText {
        anchors.centerIn: parent

        visible: root.entries.length === 0
        text: root.placeholder
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    Flickable {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Appearance.updates.sectionPaddingV

        visible: root.entries.length > 0
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list

            width: parent.width

            spacing: Appearance.spacing.none

            Repeater {
                model: root.entries

                UpdateRow {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true

                    entry: modelData
                    separated: index > 0
                }
            }
        }
    }
}
