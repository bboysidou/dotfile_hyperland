pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.clock
            label: Appearance.prayer.labelMethod
        }

        Repeater {
            model: Prayers.methods

            StyledRect {
                id: option

                required property var modelData

                readonly property bool active: Prayer.method === option.modelData.id

                Layout.fillWidth: true
                Layout.preferredHeight: Appearance.prayer.optionHeight

                color: option.active ? Colours.hover : "transparent"
                radius: Appearance.prayer.optionRounding

                StateLayer {
                    radius: parent.radius

                    onClicked: Prayer.setMethod(option.modelData.id)
                }

                StyledText {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Appearance.padding.normal
                    anchors.rightMargin: Appearance.padding.normal

                    text: option.modelData.label
                    color: option.active ? Colours.accent : Colours.text
                    font.weight: option.active ? Appearance.font.weightActive : Appearance.font.weightNormal
                    elide: Text.ElideRight
                }
            }
        }

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.shield
            label: Appearance.prayer.labelAsr
        }

        SegmentBar {
            Layout.fillWidth: true

            options: Prayers.asrSchools.map(entry => ({
                        key: entry.id,
                        label: entry.label
                    }))
            current: Prayer.asr

            onSelected: key => Prayer.setAsr(key)
        }

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.sunriseMarker
            label: Appearance.prayer.labelHighLat
        }

        SegmentBar {
            Layout.fillWidth: true

            options: Prayers.highLatRules.map(entry => ({
                        key: entry.id,
                        label: entry.label
                    }))
            current: Prayer.highLat

            onSelected: key => Prayer.setHighLat(key)
        }
    }
}
