pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

RowLayout {
    id: root

    visible: Players.available

    spacing: Appearance.dash.selectorSpacing

    Repeater {
        model: Players.list.slice(0, Appearance.dash.selectorMax)

        StyledRect {
            id: chip

            required property var modelData

            readonly property bool current: Players.active === chip.modelData

            Layout.preferredWidth: (label.implicitWidth || 0) + Appearance.dash.selectorPaddingH * 2
            Layout.preferredHeight: Appearance.dash.selectorHeight

            color: chip.current ? Colours.hover : "transparent"
            radius: Appearance.dash.selectorRounding
            border.width: chip.current ? Appearance.control.focusBorderWidth : 0
            border.color: Colours.accent

            StateLayer {
                radius: parent.radius

                onClicked: Players.select(chip.modelData)
            }

            StyledText {
                id: label

                anchors.centerIn: parent

                text: Players.label(chip.modelData)
                color: chip.current ? Colours.textBright : Colours.textMuted
                font.pixelSize: Appearance.dash.cardLabelSize
            }
        }
    }
}
