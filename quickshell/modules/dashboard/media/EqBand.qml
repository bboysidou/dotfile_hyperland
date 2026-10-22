import QtQuick
import qs.core.components
import qs.core.config

Item {
    id: root

    property real gain: 0
    property string label
    property color colour: Colours.accent

    readonly property var config: Appearance.equalizer
    readonly property real ratio: (root.gain - root.config.gainMin) / (root.config.gainMax - root.config.gainMin)
    readonly property real travel: root.config.sliderHeight - root.config.handleSize
    readonly property real handleY: (1 - root.ratio) * root.travel

    signal moved(real gain)

    function gainAt(y: real): real {
        const ratio = 1 - Math.max(0, Math.min(root.travel, y - root.config.handleSize / 2)) / root.travel;
        return root.config.gainMin + ratio * (root.config.gainMax - root.config.gainMin);
    }

    implicitHeight: root.config.sliderHeight + root.config.bandSpacing + labelText.implicitHeight

    StyledRect {
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.config.sliderWidth
        height: root.config.sliderHeight
        radius: width / 2
        color: Colours.trough
    }

    StyledRect {
        anchors.horizontalCenter: parent.horizontalCenter

        y: root.handleY + root.config.handleSize / 2
        width: root.config.sliderWidth
        height: root.config.sliderHeight - y
        radius: width / 2
        color: root.colour
    }

    StyledRect {
        anchors.horizontalCenter: parent.horizontalCenter

        y: root.handleY
        width: root.config.handleSize
        height: root.config.handleSize
        radius: width / 2
        color: Colours.textBright
    }

    StyledText {
        id: labelText

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        text: root.label
        color: Colours.textMuted
        font.pixelSize: root.config.bandLabelSize
    }

    MouseArea {
        width: parent.width
        height: root.config.sliderHeight

        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        onPressed: event => root.moved(root.gainAt(event.y))
        onPositionChanged: event => {
            if (pressed)
                root.moved(root.gainAt(event.y));
        }
        onWheel: event => root.moved(root.gain + (event.angleDelta.y > 0 ? root.config.gainStep : -root.config.gainStep))
    }
}
