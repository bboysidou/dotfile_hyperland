import QtQuick
import QtQuick.Layouts
import qs.core.config

Flickable {
    id: root

    contentHeight: list.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: list

        width: root.width

        spacing: Appearance.settings.listSpacing

        BarSection {}

        NotificationSection {}

        LookSection {}

        ClockSection {}

        WeatherSection {}

        SystemSection {}

        ClipboardSection {}

        KeyboardSection {}

        PointerSection {}
    }
}
