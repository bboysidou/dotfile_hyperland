import QtQuick
import qs.core.config
import qs.core.enums
import qs.core.helpers

MouseArea {
    id: root

    property real value: 0
    property int thickness: Appearance.slider.thickness
    property color fillColour: Colours.highlight
    property int rounding: Math.round(root.thickness * Appearance.slider.trackRoundingRatio)

    readonly property int baseHandle: Appearance.slider.handleWidth
    readonly property real centre: root.baseHandle / 2 + Num.clamp01(root.value) * Math.max(0, root.width - root.baseHandle)
    readonly property real fillEnd: Math.max(0, root.centre - root.baseHandle / 2 - Appearance.slider.handleGap)
    readonly property real trackStart: Math.min(root.width, root.centre + root.baseHandle / 2 + Appearance.slider.handleGap)

    signal moved(real value)

    function valueAt(x: real): real {
        return Num.clamp01((x - root.baseHandle / 2) / Math.max(1, root.width - root.baseHandle));
    }

    implicitWidth: Appearance.slider.length
    implicitHeight: root.thickness + Appearance.slider.handleOverhang * 2

    cursorShape: Qt.PointingHandCursor
    preventStealing: true
    opacity: root.enabled ? 1 : Appearance.control.disabledOpacity

    onPressed: event => root.moved(root.valueAt(event.x))
    onPositionChanged: event => {
        if (root.pressed)
            root.moved(root.valueAt(event.x));
    }

    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        width: root.fillEnd
        height: root.thickness
        radius: Math.min(root.rounding, width / 2)
        color: root.fillColour
        visible: width > 0
    }

    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        x: root.trackStart
        width: root.width - root.trackStart
        height: root.thickness
        radius: Math.min(root.rounding, width / 2)
        color: Colours.trough
        visible: width > 0
    }

    StyledRect {
        id: handle

        anchors.verticalCenter: parent.verticalCenter

        x: root.centre - width / 2
        width: root.pressed ? Appearance.slider.handlePressedWidth : root.baseHandle
        height: root.height
        radius: Appearance.rounding.full
        color: root.fillColour

        Behavior on width {
            Anim {
                type: AnimType.fastSpatial
            }
        }
    }
}
