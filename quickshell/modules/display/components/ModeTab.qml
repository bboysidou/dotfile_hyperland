pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.modules.display

ColumnLayout {
    id: root

    spacing: Appearance.display.sectionSpacing

    GridLayout {
        Layout.fillWidth: true

        columns: Appearance.display.gridColumns * 2
        rowSpacing: Appearance.display.gridSpacing
        columnSpacing: Appearance.display.gridSpacing

        Repeater {
            model: DisplayState.modes

            ResolutionTile {
                required property var modelData
                required property int index

                modeWidth: modelData.width
                modeHeight: modelData.height
                selected: index === DisplayState.modeIndex

                onTriggered: DisplayState.selectMode(index)
            }
        }
    }

    RateSlider {
        Layout.fillWidth: true

        rates: DisplayState.rates
        index: DisplayState.rateIndex

        onPicked: index => DisplayState.selectRate(index)
    }
}
