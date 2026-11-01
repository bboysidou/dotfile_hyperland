import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    required property int value

    visible: root.value >= 0
    spacing: Appearance.notif.actionSpacing

    Meter {
        Layout.fillWidth: true

        thickness: Appearance.notif.progressThickness
        minFill: 0
        value: root.value / Appearance.notif.progressMax
        fillColour: Colours.accent
    }

    StyledText {
        text: Appearance.notif.progressTemplate.arg(root.value)
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }
}
