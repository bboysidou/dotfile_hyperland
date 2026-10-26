import QtQuick
import QtQuick.Layouts
import qs.core.config

RowLayout {
    id: root

    property color accent: Colours.accent

    signal focusRequested
    signal focusReleased

    spacing: Appearance.dash.spacing

    ColumnLayout {
        Layout.preferredWidth: Appearance.prayer.listWidth
        Layout.fillWidth: true
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        PrayerNextCard {
            Layout.fillWidth: true

            accent: root.accent
        }

        PrayerListCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            accent: root.accent
        }
    }

    ColumnLayout {
        Layout.preferredWidth: Appearance.prayer.placeWidth
        Layout.fillWidth: true
        Layout.fillHeight: true

        spacing: Appearance.dash.spacing

        PrayerPlaceCard {
            Layout.fillWidth: true

            accent: root.accent

            onFocusRequested: root.focusRequested()
            onFocusReleased: root.focusReleased()
        }

        PrayerSettingsCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            accent: root.accent
        }
    }
}
