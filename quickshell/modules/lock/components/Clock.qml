pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.services

Column {
    id: root

    spacing: Appearance.lock.centreSpacing

    Column {
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: Appearance.lock.clockSpacing

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDateTime(Time.now, Appearance.lock.hourFormat)
            color: Colours.accent
            font.family: Appearance.lock.clockFont
            font.pixelSize: Appearance.lock.clockFontSize
            font.weight: Appearance.lock.clockWeight
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDateTime(Time.now, Appearance.lock.minuteFormat)
            color: Colours.textBright
            font.family: Appearance.lock.clockFont
            font.pixelSize: Appearance.lock.clockFontSize
            font.weight: Appearance.lock.clockWeight
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: Qt.formatDateTime(Time.now, Appearance.lock.dateFormat)
        color: Colours.textBright
        font.family: Appearance.lock.labelFont
        font.pixelSize: Appearance.lock.dateFontSize
        font.weight: Appearance.lock.labelWeight
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: Appearance.lock.greetingTemplate.arg(Lock.user).arg(Lock.greeting)
        color: Colours.textMuted
        font.family: Appearance.lock.labelFont
        font.pixelSize: Appearance.lock.greetingFontSize
        font.weight: Appearance.lock.labelWeight
    }
}
