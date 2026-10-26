import QtQuick
import qs.core.config

Item {
    id: root

    property alias text: label.text
    property alias color: label.color
    property alias font: label.font
    property alias textFormat: label.textFormat
    property alias verticalAlignment: label.verticalAlignment
    property int horizontalAlignment: Text.AlignLeft
    property real offset: 0

    readonly property real overflow: Math.max(0, label.implicitWidth - root.width)
    readonly property bool scrolling: root.visible && root.overflow > 0

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    clip: root.overflow > 0

    onOverflowChanged: root.restart()
    onScrollingChanged: root.restart()

    function restart(): void {
        sweep.stop();
        root.offset = 0;
        if (root.scrolling)
            sweep.start();
    }

    StyledText {
        id: label

        x: -root.offset
        width: Math.max(root.width, label.implicitWidth)
        height: root.height
        horizontalAlignment: root.horizontalAlignment
    }

    SequentialAnimation {
        id: sweep

        loops: Animation.Infinite

        PauseAnimation {
            duration: Appearance.marquee.scrollHold
        }

        NumberAnimation {
            target: root
            property: "offset"
            to: root.overflow
            duration: root.overflow * Appearance.marquee.scrollPixelDuration
            easing.type: Easing.InOutSine
        }

        PauseAnimation {
            duration: Appearance.marquee.scrollHold
        }

        NumberAnimation {
            target: root
            property: "offset"
            to: 0
            duration: root.overflow * Appearance.marquee.scrollPixelDuration
            easing.type: Easing.InOutSine
        }
    }
}
