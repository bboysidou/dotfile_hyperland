import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property string glyph
    property real value: 0
    property color colour: Colours.accent
    property real wheelStep: Appearance.slider.wheelStep

    signal moved(real value)

    Layout.fillWidth: true

    spacing: Appearance.powerPanel.sliderRowSpacing

    Icon {
        text: root.glyph
        color: root.colour
        font.pixelSize: Appearance.powerPanel.sliderIconSize
    }

    Slider {
        Layout.fillWidth: true

        value: root.value
        fillColour: root.colour
        wheelStep: root.wheelStep

        onMoved: value => root.moved(value)
    }
}
