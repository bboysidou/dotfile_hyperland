import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers

Item {
    id: root

    property bool hasBattery: false
    property int percent: 0
    property bool charging: false
    property string status

    ColumnLayout {
        anchors.centerIn: parent

        spacing: Appearance.orbit.coreTextSpacing

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            spacing: Appearance.powerPanel.heroTextSpacing

            Icon {
                text: root.hasBattery ? Glyphs.batteryRamp(root.percent, root.charging) : Icons.powerPlug
                color: Colours.surface
                font.pixelSize: Appearance.powerPanel.percentGlyphSize
            }

            StyledText {
                visible: root.hasBattery
                text: Appearance.scale.percentTemplate.arg(root.percent)
                color: Colours.surface
                font.pixelSize: Appearance.powerPanel.percentSize
                font.bold: true
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter

            text: root.status
            color: Colours.surface
            font.pixelSize: Appearance.powerPanel.statusSize
            font.letterSpacing: Appearance.powerPanel.statusLetterSpacing
        }
    }
}
