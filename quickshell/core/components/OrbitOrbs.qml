import QtQuick
import qs.core.config
import qs.core.enums

Item {
    id: root

    property real angle: 0
    property bool powered: true
    property bool danger: false
    property color accent: Colours.accent

    readonly property color primaryTint: {
        if (root.danger)
            return Colours.critical;
        return root.powered ? root.accent : Colours.trough;
    }

    readonly property color secondaryTint: {
        if (root.danger)
            return Qt.darker(Colours.critical, Appearance.orbit.orbSecondaryShade);
        return root.powered ? root.accent : Colours.elevated;
    }

    StyledRect {
        id: primary

        readonly property real drift: Appearance.orbit.orbPrimaryDriftX
        readonly property real lift: Appearance.orbit.orbPrimaryDriftY
        readonly property real rate: Appearance.orbit.orbPrimaryRate

        width: root.width * Appearance.orbit.orbPrimaryRatio
        height: width
        radius: width / 2

        x: (root.width - width) / 2 + Math.cos(root.angle * primary.rate) * primary.drift
        y: (root.height - height) / 2 + Math.sin(root.angle * primary.rate) * primary.lift

        color: root.primaryTint
        opacity: {
            const orbit = Appearance.orbit;
            if (!root.powered)
                return orbit.orbIdleOpacity;
            return root.danger ? orbit.orbPrimaryDangerOpacity : orbit.orbPrimaryOpacity;
        }
        visible: opacity > 0

        Behavior on opacity {
            Anim {
                type: AnimType.slowEffects
            }
        }
    }

    StyledRect {
        id: secondary

        readonly property real drift: Appearance.orbit.orbSecondaryDriftX
        readonly property real lift: Appearance.orbit.orbSecondaryDriftY
        readonly property real rate: Appearance.orbit.orbSecondaryRate

        width: root.width * Appearance.orbit.orbSecondaryRatio
        height: width
        radius: width / 2

        x: (root.width - width) / 2 + Math.sin(root.angle * secondary.rate) * secondary.drift
        y: (root.height - height) / 2 + Math.cos(root.angle * secondary.rate) * secondary.lift

        color: root.secondaryTint
        opacity: {
            const orbit = Appearance.orbit;
            if (!root.powered)
                return orbit.orbIdleOpacity / 2;
            return root.danger ? orbit.orbSecondaryDangerOpacity : orbit.orbSecondaryOpacity;
        }
        visible: opacity > 0

        Behavior on opacity {
            Anim {
                type: AnimType.slowEffects
            }
        }
    }
}
