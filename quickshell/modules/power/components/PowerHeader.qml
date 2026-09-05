import QtQuick
import qs.core.components
import qs.core.config
import qs.services

Column {
    id: root

    spacing: Appearance.power.headerSpacing

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter

        text: Qt.formatDateTime(Time.now, Appearance.power.clockFormat)
        color: Colours.textBright
        font.family: Appearance.font.family.mono
        font.pixelSize: Appearance.power.clockSize
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter

        text: Appearance.power.uptimeTemplate.arg(Uptime.text)
        color: Colours.textMuted
        font.pixelSize: Appearance.power.uptimeSize
    }
}
