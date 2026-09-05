import QtQuick
import QtQuick.Layouts
import qs.core.config

RowLayout {
    id: root

    property bool active: true

    spacing: Appearance.dash.spacing

    ColumnLayout {
        Layout.preferredWidth: Appearance.dash.calendarWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        DateTimeCard {
            Layout.fillWidth: true
        }

        CalendarCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    ColumnLayout {
        Layout.preferredWidth: Appearance.dash.clockWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        WorldClockCard {
            Layout.fillWidth: true
        }

        ResourcesCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    ColumnLayout {
        Layout.preferredWidth: Appearance.dash.mediaCardWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        MediaCard {
            Layout.fillWidth: true

            active: root.active
        }

        NotificationsCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
