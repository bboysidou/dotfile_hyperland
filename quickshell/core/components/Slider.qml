import QtQuick
import qs.core.config
import qs.core.helpers

MouseArea {
    id: root

    property real value: 0

    signal moved(real value)

    function valueAt(x: real): real {
        return Num.clamp(x / root.width, 0, 1);
    }

    implicitWidth: Appearance.bar.sliderTroughWidth
    implicitHeight: Appearance.bar.sliderTroughHeight

    cursorShape: Qt.PointingHandCursor
    preventStealing: true

    onPressed: event => root.moved(root.valueAt(event.x))
    onPositionChanged: event => {
        if (root.pressed)
            root.moved(root.valueAt(event.x));
    }

    Meter {
        anchors.fill: parent

        value: root.value
    }
}
