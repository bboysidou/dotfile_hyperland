import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

StyledRect {
    id: root

    required property var entry

    readonly property var config: Appearance.errorLog
    readonly property var settings: Appearance.settings
    readonly property color tint: root.entry.level === LogLevel.warn ? Colours.warning : Colours.critical

    property bool expanded: false

    signal toggled

    implicitHeight: layout.implicitHeight + root.settings.cardPadding * 2

    radius: root.settings.cardRounding
    color: Colours.pill
    clip: true

    StyledRect {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: root.config.stripeWidth
        color: root.tint
    }

    StateLayer {
        onClicked: root.toggled()
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.settings.cardPadding

        spacing: root.settings.cardSpacing

        RowLayout {
            Layout.fillWidth: true

            spacing: root.config.metaSpacing

            Icon {
                text: root.entry.level === LogLevel.warn ? Icons.alert : Icons.failure
                color: root.tint
                font.pixelSize: root.settings.commandIconSize
            }

            StyledText {
                text: LogLevel.labels[root.entry.level]
                color: root.tint
                font.pixelSize: Appearance.font.size.small
                font.weight: Appearance.font.weightActive
            }

            StyledText {
                Layout.fillWidth: true

                text: root.entry.source
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
                elide: Text.ElideMiddle
            }

            StyledText {
                visible: root.entry.count > 1
                text: root.config.countTemplate.arg(root.entry.count)
                color: root.tint
                font.pixelSize: Appearance.font.size.small
            }

            StyledText {
                text: Qt.formatDateTime(new Date(root.entry.time), root.config.timeFormat)
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }

            IconButton {
                icon: Icons.copy
                size: root.settings.commandIconSize

                onTriggered: ErrorLog.copy(root.entry)
            }
        }

        StyledText {
            Layout.fillWidth: true

            text: root.entry.message
            color: Colours.textBright
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WrapAnywhere
            maximumLineCount: root.expanded ? root.config.expandedLines : root.config.collapsedLines
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.expanded && root.entry.details !== ""
            text: root.entry.details
            color: Colours.textMuted
            font.family: Appearance.font.family.mono
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WrapAnywhere
        }
    }
}
