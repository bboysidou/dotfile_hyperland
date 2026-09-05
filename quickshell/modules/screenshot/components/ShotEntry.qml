pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property var entry
    required property bool selected

    signal clicked

    color: root.selected ? Colours.hover : "transparent"
    radius: Appearance.shot.rowRounding

    implicitHeight: Appearance.shot.iconSize + Appearance.shot.rowPaddingV * 2

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.shot.rowPaddingH
        anchors.rightMargin: Appearance.shot.rowPaddingH

        spacing: Appearance.shot.rowContentSpacing

        Item {
            implicitWidth: Appearance.shot.iconSize
            implicitHeight: Appearance.shot.iconSize

            Icon {
                anchors.centerIn: parent

                text: root.entry.icon
                color: root.selected ? Colours.accent : Colours.textMuted
                font.pixelSize: Appearance.shot.iconSize
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Appearance.spacing.none

            StyledText {
                Layout.fillWidth: true

                text: root.entry.label
                color: root.selected ? Colours.textBright : Colours.text
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true

                text: root.entry.subtitle
                color: Colours.textMuted
                opacity: Appearance.shot.subtitleOpacity
                font.pixelSize: Appearance.font.size.small
                elide: Text.ElideRight
            }
        }
    }
}
