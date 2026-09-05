pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
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
            label: Appearance.dash.labelWorldClock
        }

        Repeater {
            model: Appearance.dash.clockZones

            RowLayout {
                id: row

                required property int index

                readonly property var zone: Time.zones[row.index] ?? null

                Layout.fillWidth: true
                Layout.preferredHeight: Appearance.dash.clockRowHeight

                spacing: Appearance.dash.cardSpacing

                StyledText {
                    Layout.fillWidth: true

                    text: row.zone?.label ?? ""
                    color: Colours.text
                    elide: Text.ElideRight
                }

                StyledText {
                    text: (row.zone?.dayShift ?? 0) === 0 ? "" : (row.zone.dayShift > 0 ? Appearance.dash.clockNextDay : Appearance.dash.clockPrevDay)
                    color: Colours.textMuted
                    font.pixelSize: Appearance.dash.cardLabelSize
                }

                StyledText {
                    text: row.zone?.time ?? Appearance.dash.clockPlaceholder
                    color: (row.zone?.known ?? false) ? Colours.textBright : Colours.textMuted
                    font.weight: Appearance.font.weightActive
                }
            }
        }
    }
}
