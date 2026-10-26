import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string label
    property string letter
    property bool active: false

    signal triggered

    implicitWidth: row.implicitWidth + Appearance.launcher.fitChipPadding * 2
    implicitHeight: Appearance.launcher.fitChipHeight

    radius: Appearance.rounding.full
    color: root.active ? Colours.accent : Colours.elevated

    Row {
        id: row

        anchors.centerIn: parent

        spacing: Appearance.launcher.fitChipGap

        StyledText {
            text: root.label
            color: root.active ? Colours.surface : Colours.text
            font.pixelSize: Appearance.launcher.fitChipSize
        }

        StyledText {
            text: Appearance.launcher.fitKeyTemplate.arg(root.letter)
            color: root.active ? Colours.surface : Colours.textMuted
            opacity: Appearance.launcher.fitKeyOpacity
            font.pixelSize: Appearance.launcher.fitChipSize
        }
    }

    StateLayer {
        radius: root.radius

        onClicked: root.triggered()
    }
}
