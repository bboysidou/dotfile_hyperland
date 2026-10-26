pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings
    readonly property bool full: Prefs.worldClocks.length >= root.config.maxClocks

    title: root.config.labelWorldClocks
    glyph: Icons.clock

    Repeater {
        model: Time.zones

        SettingRow {
            required property var modelData

            label: modelData.label

            StyledText {
                anchors.verticalCenter: parent.verticalCenter

                text: modelData.time
                color: Colours.textMuted
            }

            IconButton {
                icon: Icons.close

                onTriggered: Prefs.removeClock(modelData.zone)
            }
        }
    }

    StyledText {
        Layout.fillWidth: true

        visible: root.full
        text: root.config.hintClocksFull
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    SearchPick {
        visible: !root.full
        placeholder: root.config.placeholderZone
        choices: Prefs.timezones
        exclude: Prefs.worldClocks.map(entry => entry.zone)

        onOpened: Prefs.loadTimezones()
        onPicked: value => Prefs.addClock(value)
    }
}
