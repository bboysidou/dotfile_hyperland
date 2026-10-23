import QtQuick
import QtQuick.Layouts
import qs.core.config

Flickable {
    id: root

    contentHeight: column.implicitHeight
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    ColumnLayout {
        id: column

        width: root.width

        spacing: Appearance.batteryTab.sectionSpacing

        HealthChips {}

        BatteryStats {}

        HistoryCard {}

        PowerSplit {}

        ChargerCard {}

        CareCard {}
    }
}
