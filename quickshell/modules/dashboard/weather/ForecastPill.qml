import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string time
    property string glyph
    property string temp
    property bool active: false
    property real depth: 1

    readonly property var config: Appearance.weather
    readonly property real zoom: root.active ? root.config.pillActiveScale : 1

    function sized(base: int): int {
        return Math.round(base * root.zoom);
    }

    width: root.config.pillWidth * root.zoom * root.depth
    height: root.config.pillHeight * root.zoom * root.depth

    radius: width / 2
    color: root.active ? Colours.accent : Colours.elevated

    Column {
        anchors.centerIn: parent

        spacing: root.sized(root.config.pillSpacing)

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.time
            color: root.active ? Colours.surface : Colours.textMuted
            font.pixelSize: root.sized(root.config.pillTimeSize)
        }

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.glyph
            color: root.active ? Colours.surface : Colours.text
            font.pixelSize: root.sized(root.config.pillGlyphSize)
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.temp
            color: root.active ? Colours.surface : Colours.textBright
            font.pixelSize: root.sized(root.config.pillTempSize)
            font.bold: true
        }
    }
}
