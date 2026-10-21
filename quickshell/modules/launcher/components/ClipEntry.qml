pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.services

StyledRect {
    id: root

    required property var entry
    required property bool selected

    readonly property bool thumbReady: root.entry.image && (Clipboard.thumbs[root.entry.id] ?? false)

    signal clicked

    color: root.selected ? Colours.hover : "transparent"
    radius: Appearance.launcher.rowRounding

    implicitHeight: Appearance.clipboard.thumbHeight + Appearance.launcher.rowPaddingV * 2

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

        ClippingRectangle {
            implicitWidth: Appearance.clipboard.thumbWidth
            implicitHeight: Appearance.clipboard.thumbHeight

            radius: Appearance.clipboard.thumbRounding
            color: Colours.hover

            Image {
                anchors.fill: parent

                visible: root.thumbReady
                source: root.thumbReady ? `file://${root.entry.thumb}` : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(Appearance.clipboard.thumbWidth, Appearance.clipboard.thumbHeight)
            }

            Icon {
                anchors.centerIn: parent

                visible: !root.thumbReady
                text: root.entry.image ? Icons.wallpaper : Icons.clipText
                color: Colours.textMuted
                font.pixelSize: Appearance.launcher.iconSize
            }
        }

        StyledText {
            Layout.fillWidth: true

            text: root.entry.label
            color: root.selected ? Colours.textBright : Colours.text
            wrapMode: Text.Wrap
            maximumLineCount: Appearance.clipboard.textLines
            elide: Text.ElideRight
        }
    }
}
