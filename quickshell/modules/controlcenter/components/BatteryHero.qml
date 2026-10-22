pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.helpers

Item {
    id: root

    property bool hasBattery: false
    property int percent: 0
    property bool charging: false
    property string status
    property color colour: Colours.accent

    Repeater {
        model: Appearance.powerPanel.haloRatios

        Rectangle {
            required property real modelData

            anchors.centerIn: parent

            width: Appearance.powerPanel.ringSize * modelData
            height: width
            radius: width / 2
            color: root.colour
            opacity: Appearance.powerPanel.haloOpacity
        }
    }

    Ring {
        anchors.centerIn: parent

        implicitWidth: Appearance.powerPanel.ringSize
        implicitHeight: Appearance.powerPanel.ringSize

        value: root.hasBattery ? root.percent / Appearance.scale.percent : 1
        colour: root.colour
        radiusRatio: Appearance.powerPanel.ringRadiusRatio
        thicknessRatio: Appearance.powerPanel.ringThicknessRatio
    }

    Column {
        anchors.centerIn: parent

        spacing: Appearance.powerPanel.heroTextSpacing

        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: Appearance.powerPanel.heroTextSpacing

            Icon {
                anchors.verticalCenter: parent.verticalCenter

                text: root.hasBattery ? Glyphs.batteryRamp(root.percent, root.charging) : Icons.powerPlug
                color: root.colour
                font.pixelSize: Appearance.powerPanel.percentGlyphSize
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter

                visible: root.hasBattery
                text: Appearance.scale.percentTemplate.arg(root.percent)
                color: Colours.textBright
                font.pixelSize: Appearance.powerPanel.percentSize
                font.bold: true
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.status
            color: Colours.textMuted
            font.pixelSize: Appearance.powerPanel.statusSize
            font.letterSpacing: Appearance.powerPanel.statusLetterSpacing
        }
    }
}
