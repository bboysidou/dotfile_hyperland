pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    property var rates: []
    property int index: 0

    readonly property int steps: Math.max(1, root.rates.length - 1)

    signal picked(int index)

    function label(rate: string): string {
        const value = Number(rate);
        return Number.isInteger(value) ? String(value) : rate;
    }

    spacing: Appearance.display.tickTopMargin

    Slider {
        id: slider

        Layout.fillWidth: true
        Layout.topMargin: Appearance.display.sliderTopMargin

        enabled: root.rates.length > 1
        value: root.rates.length > 1 ? root.index / root.steps : 1
        fillColour: Colours.accent

        onMoved: value => root.picked(Math.round(value * root.steps))
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Appearance.display.tickSize * 2

        Repeater {
            model: root.rates

            StyledText {
                required property string modelData
                required property int index

                x: slider.baseHandle / 2 + (root.rates.length > 1 ? index / root.steps : 1) * (parent.width - slider.baseHandle) - width / 2

                text: root.label(modelData)
                color: index === root.index ? Colours.accent : Colours.textMuted
                font.pixelSize: Appearance.display.tickSize
                font.bold: index === root.index
            }
        }
    }
}
