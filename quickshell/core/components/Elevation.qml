import QtQuick
import QtQuick.Effects
import qs.core.config
import qs.core.enums
import qs.core.helpers

RectangularShadow {
    id: root

    property int level: 0

    property real dp: Appearance.elevation.levels[Num.clamp(root.level, 0, Appearance.elevation.levels.length - 1)]

    color: Qt.alpha(Colours.shadow, Appearance.elevation.opacity)
    blur: (dp * Appearance.elevation.blurScale) ** Appearance.elevation.blurExponent
    spread: -dp * Appearance.elevation.spreadScale + (dp * Appearance.elevation.spreadCurve) ** 2
    offset.y: dp / 2

    Behavior on dp {
        Anim {
            type: AnimType.slowEffects
        }
    }
}
