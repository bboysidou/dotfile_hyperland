pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.helpers

StyledRect {
    id: root

    required property var entry
    required property bool selected

    readonly property string subtitle: root.entry.genericName || root.entry.comment
    readonly property string iconSource: Fmt.icon(root.entry.icon)

    signal clicked

    color: root.selected ? Colours.hover : "transparent"
    radius: Appearance.launcher.rowRounding

    implicitHeight: Appearance.launcher.iconSize + Appearance.launcher.rowPaddingV * 2

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.launcher.rowPaddingH
        anchors.rightMargin: Appearance.launcher.rowPaddingH

        spacing: Appearance.launcher.rowContentSpacing

        Item {
            implicitWidth: Appearance.launcher.iconSize
            implicitHeight: Appearance.launcher.iconSize

            IconImage {
                anchors.fill: parent

                visible: root.iconSource !== ""
                source: root.iconSource
            }

            Icon {
                anchors.centerIn: parent

                visible: root.iconSource === ""
                text: Icons.launcherApp
                color: Colours.textMuted
                font.pixelSize: Appearance.launcher.iconSize
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Appearance.spacing.none

            StyledText {
                Layout.fillWidth: true

                text: root.entry.name
                color: root.selected ? Colours.textBright : Colours.text
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true

                visible: root.subtitle !== ""
                text: root.subtitle
                color: Colours.textMuted
                opacity: Appearance.launcher.subtitleOpacity
                font.pixelSize: Appearance.font.size.small
                elide: Text.ElideRight
            }
        }
    }
}
