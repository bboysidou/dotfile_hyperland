import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    required property var entry
    required property bool selected
    required property bool live
    property color accent: Colours.accent

    readonly property bool isWindow: root.entry.source === ShareSource.window

    signal clicked
    signal activated

    color: root.selected ? Colours.hover : Colours.pill
    radius: Appearance.share.tileRounding
    border.width: root.selected ? Appearance.share.tileBorderWidth : 0
    border.color: root.accent

    StateLayer {
        onClicked: root.clicked()
        onDoubleClicked: root.activated()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.share.tilePadding

        spacing: Appearance.share.tileSpacing

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: Colours.trough
            radius: Appearance.share.previewRounding
            clip: true

            ScreencopyView {
                id: preview

                anchors.centerIn: parent

                width: preview.implicitWidth
                height: preview.implicitHeight

                constraintSize: Qt.size(parent.width, parent.height)
                captureSource: root.live ? root.entry.capture : null
                live: true
                paintCursor: false
            }

            Icon {
                anchors.centerIn: parent

                visible: !preview.hasContent
                text: root.isWindow ? Icons.shareWindow : root.entry.source === ShareSource.workspace ? Icons.dashTab : Icons.shareScreen
                color: Colours.textMuted
                font.pixelSize: Appearance.share.previewIconSize
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.share.labelSpacing

            IconImage {
                implicitSize: Appearance.share.labelIconSize

                visible: root.entry.icon !== ""
                source: root.entry.icon
            }

            ScrollText {
                Layout.fillWidth: true

                text: root.entry.title
                color: root.selected ? Colours.textBright : Colours.text
                font.pixelSize: Appearance.share.bodySize
            }

            StyledText {
                text: root.entry.subtitle
                color: Colours.textMuted
                font.pixelSize: Appearance.share.bodySize
                visible: !root.isWindow
            }
        }
    }
}
