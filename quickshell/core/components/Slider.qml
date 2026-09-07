import QtQuick
import qs.core.config
import qs.core.helpers

MouseArea {
    id: root

    property real value: 0
    property alias thickness: meter.thickness
    property alias fillColour: meter.fillColour
    property alias rounding: meter.rounding

    signal moved(real value)

    function valueAt(x: real): real {
        return Num.clamp(x / root.width, 0, 1);
    }

    implicitWidth: Appearance.slider.length
    implicitHeight: meter.thickness

    cursorShape: Qt.PointingHandCursor
    preventStealing: true

    onPressed: event => root.moved(root.valueAt(event.x))
    onPositionChanged: event => {
        if (root.pressed)
            root.moved(root.valueAt(event.x));
    }

    Meter {
        id: meter

        anchors.fill: parent

        value: root.value
    }
}
