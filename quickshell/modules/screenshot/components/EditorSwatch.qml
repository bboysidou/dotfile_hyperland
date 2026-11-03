import QtQuick
import qs.core.components
import qs.core.config

Item {
    id: root

    required property color swatch
    property bool active: false

    signal picked

    implicitWidth: Appearance.editor.swatchSize + Appearance.editor.swatchRing * 4
    implicitHeight: implicitWidth

    Rectangle {
        anchors.fill: parent

        radius: width / 2
        color: "transparent"
        border.width: root.active ? Appearance.editor.swatchRing : 0
        border.color: Colours.text
    }

    Rectangle {
        anchors.centerIn: parent

        width: Appearance.editor.swatchSize
        height: width
        radius: width / 2
        color: root.swatch
        border.width: 1
        border.color: Colours.border
    }

    StateLayer {
        radius: width / 2

        onClicked: root.picked()
    }
}
