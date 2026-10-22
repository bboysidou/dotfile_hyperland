import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

ColumnLayout {
    id: root

    property var day: null
    property date date: new Date()
    property bool canBack: false
    property bool canForward: false

    readonly property var config: Appearance.weather

    signal stepped(int delta)

    spacing: root.config.spacing

    RowLayout {
        Layout.fillWidth: true

        IconButton {
            icon: Icons.chevronLeft
            disabled: !root.canBack

            onTriggered: root.stepped(-1)
        }

        StyledText {
            Layout.fillWidth: true

            text: Qt.formatDateTime(root.date, root.config.dayFormat).toUpperCase()
            color: Colours.textBright
            font.pixelSize: root.config.dayNavSize
            font.letterSpacing: root.config.dayLetterSpacing
            horizontalAlignment: Text.AlignHCenter
        }

        IconButton {
            icon: Icons.chevronRight
            disabled: !root.canForward

            onTriggered: root.stepped(1)
        }
    }

    StyledText {
        Layout.alignment: Qt.AlignRight

        text: root.day ? root.config.tempTemplate.arg(Math.round(root.day.temp)) : root.config.labelNoWeather
        color: Colours.textBright
        font.pixelSize: root.day ? root.config.tempSize : root.config.conditionSize
        font.bold: true
    }

    StyledText {
        Layout.alignment: Qt.AlignRight

        visible: root.day !== null
        text: root.day ? Weather.describe(root.day.code) : ""
        color: Colours.text
        font.pixelSize: root.config.conditionSize
    }

    Item {
        Layout.fillHeight: true
    }

    RowLayout {
        Layout.fillWidth: true

        visible: root.day !== null
        spacing: root.config.ringRowSpacing

        StatRing {
            value: (root.day?.wind ?? 0) / root.config.windScaleMax
            text: root.config.windTemplate.arg(Math.round(root.day?.wind ?? 0))
            glyph: Icons.weatherWind
            label: root.config.labelWind
        }

        StatRing {
            value: (root.day?.humidity ?? 0) / Appearance.scale.percent
            text: root.config.percentTemplate.arg(root.day?.humidity ?? 0)
            glyph: Icons.waterPercent
            label: root.config.labelHumidity
        }

        StatRing {
            value: (root.day?.rain ?? 0) / Appearance.scale.percent
            text: root.config.percentTemplate.arg(root.day?.rain ?? 0)
            glyph: Icons.water
            label: root.config.labelRain
        }

        StatRing {
            value: ((root.day?.feels ?? 0) - root.config.feelsScaleMin) / (root.config.feelsScaleMax - root.config.feelsScaleMin)
            text: root.config.tempTemplate.arg((root.day?.feels ?? 0).toFixed(1))
            glyph: Icons.thermometer
            label: root.config.labelFeels
        }
    }
}
