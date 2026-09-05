import QtQuick
import qs.core.config
import qs.core.enums

MouseArea {
    id: root

    property bool disabled
    property color layerColour: Colours.textBright
    property real radius: root.parent?.radius ?? 0

    readonly property real stateOpacity: {
        if (root.disabled)
            return 0;
        if (root.pressed)
            return Appearance.stateLayer.pressOpacity;
        if (root.containsMouse)
            return Appearance.stateLayer.hoverOpacity;
        return 0;
    }

    anchors.fill: parent

    enabled: !root.disabled
    hoverEnabled: true
    cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent

        color: root.layerColour
        opacity: root.stateOpacity
        radius: root.radius
        antialiasing: true

        Behavior on opacity {
            Anim {
                type: AnimType.defaultEffects
            }
        }
    }
}
