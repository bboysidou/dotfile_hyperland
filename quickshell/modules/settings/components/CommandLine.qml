import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

StyledRect {
    id: root

    required property string label
    required property string command

    readonly property var config: Appearance.settings
    readonly property bool copied: Daemons.copied === root.command

    Layout.fillWidth: true
    implicitHeight: Math.max(root.config.commandHeight, line.implicitHeight + root.config.commandSpacing * 2)

    radius: root.config.commandRounding
    color: Colours.trough

    RowLayout {
        id: line

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: root.config.commandPaddingH
        anchors.rightMargin: root.config.commandPaddingH

        spacing: root.config.commandPaddingH

        StyledText {
            Layout.preferredWidth: root.config.commandLabelWidth
            Layout.alignment: Qt.AlignTop

            text: root.label
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        StyledText {
            Layout.fillWidth: true

            text: root.command
            color: Colours.textBright
            font.family: Appearance.font.family.mono
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        StyledText {
            Layout.alignment: Qt.AlignTop

            visible: root.copied
            text: root.config.labelCopied
            color: Colours.accent
            font.pixelSize: Appearance.font.size.small
        }

        Icon {
            Layout.alignment: Qt.AlignTop

            visible: !root.copied
            text: Icons.copy
            color: Colours.textMuted
            font.pixelSize: root.config.commandIconSize
        }
    }

    StateLayer {
        radius: root.radius

        onClicked: Daemons.copy(root.command)
    }
}
