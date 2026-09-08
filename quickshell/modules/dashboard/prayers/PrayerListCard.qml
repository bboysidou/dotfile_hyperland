pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
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
            label: Appearance.prayer.labelToday
        }

        Repeater {
            model: Prayer.today

            PrayerRow {
                id: row

                required property var modelData

                entry: row.modelData
                marker: row.modelData.name === PrayerName.sunrise
                active: !!Prayer.current && !!row.modelData.date && Prayer.current.name === row.modelData.name && Prayer.current.date.getTime() === row.modelData.date.getTime()
                elapsed: !!row.modelData.date && row.modelData.date < Time.now && !row.active
            }
        }
    }
}
