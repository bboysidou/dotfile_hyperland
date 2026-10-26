import QtQuick
import qs.core.config

StyledRect {
    id: root

    property string glyph
    property string label
    property bool accent: false
    property color tint: Colours.accent
    property bool disabled: false

    signal triggered

    implicitWidth: row.implicitWidth + Appearance.display.buttonPadding * 2
    implicitHeight: Appearance.display.buttonHeight

    radius: Appearance.rounding.full
    color: root.accent ? root.tint : Colours.elevated
    opacity: root.disabled ? Appearance.control.disabledOpacity : 1

    Row {
        id: row

        anchors.centerIn: parent

        spacing: Appearance.display.buttonSpacing

        Icon {
            anchors.verticalCenter: parent.verticalCenter

            text: root.glyph
            color: root.accent ? Colours.surface : Colours.textBright
            font.pixelSize: Appearance.display.buttonIconSize
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter

            text: root.label
            color: root.accent ? Colours.surface : Colours.textBright
            font.bold: true
        }
    }

    StateLayer {
        radius: root.radius
        disabled: root.disabled

        onClicked: root.triggered()
    }
}
