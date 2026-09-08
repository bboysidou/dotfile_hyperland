import QtQuick
import QtQuick.Layouts
import qs.core.config

RowLayout {
    id: root

    signal focusRequested
    signal focusReleased

    spacing: Appearance.dash.spacing

    ColumnLayout {
        Layout.preferredWidth: Appearance.prayer.listWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        PrayerNextCard {
            Layout.fillWidth: true
        }

        PrayerListCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    ColumnLayout {
        Layout.preferredWidth: Appearance.prayer.placeWidth
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        PrayerPlaceCard {
            Layout.fillWidth: true

            onFocusRequested: root.focusRequested()
            onFocusReleased: root.focusReleased()
        }

        PrayerSettingsCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
