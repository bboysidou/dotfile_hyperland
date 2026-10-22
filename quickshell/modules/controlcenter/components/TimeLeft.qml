import QtQuick
import qs.core.components
import qs.core.config

Row {
    id: root

    property real seconds: 0

    readonly property bool known: root.seconds > 0
    readonly property int hours: Math.floor(root.seconds / Appearance.powerPanel.secondsPerHour)
    readonly property int minutes: Math.floor(root.seconds % Appearance.powerPanel.secondsPerHour / Appearance.powerPanel.secondsPerMinute)

    function pad(value: int): string {
        return root.known ? String(value).padStart(Appearance.powerPanel.timeDigits, "0") : Appearance.powerPanel.timeUnknown;
    }

    spacing: Appearance.powerPanel.timeSpacing

    TimeTile {
        value: root.pad(root.hours)
        unit: Appearance.powerPanel.hoursLabel
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter

        text: Appearance.powerPanel.timeSeparator
        color: Colours.textMuted
        font.pixelSize: Appearance.powerPanel.timeSeparatorSize
    }

    TimeTile {
        value: root.pad(root.minutes)
        unit: Appearance.powerPanel.minutesLabel
    }
}
