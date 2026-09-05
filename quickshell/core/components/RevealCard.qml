import QtQuick
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    property bool revealed: false
    property real scaleFrom: 1
    property int elevation: Appearance.elevation.panel

    color: Colours.surface
    border.width: 0
    border.color: Colours.accent

    opacity: root.revealed ? 1 : 0
    scale: root.revealed ? 1 : root.scaleFrom

    Behavior on opacity {
        Anim {
            type: AnimType.fastEffects
        }
    }

    Behavior on scale {
        Anim {
            type: AnimType.fastSpatial
        }
    }

    Elevation {
        anchors.fill: parent

        level: root.revealed ? root.elevation : 0
        radius: root.radius
        z: -1
    }
}
