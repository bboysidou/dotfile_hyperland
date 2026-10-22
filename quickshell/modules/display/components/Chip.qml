import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string label
    property bool active: false

    signal triggered

    implicitWidth: text.implicitWidth + Appearance.display.chipPadding * 2
    implicitHeight: Appearance.display.chipHeight

    radius: Appearance.rounding.full
    color: root.active ? Colours.accent : Colours.elevated

    StyledText {
        id: text

        anchors.centerIn: parent

        text: root.label
        color: root.active ? Colours.surface : Colours.text
        font.pixelSize: Appearance.display.chipSize
    }

    StateLayer {
        radius: root.radius

        onClicked: root.triggered()
    }
}
