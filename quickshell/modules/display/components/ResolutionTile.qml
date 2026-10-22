import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property int modeWidth
    required property int modeHeight
    property bool selected: false

    readonly property string size: Appearance.display.modeTemplate.arg(root.modeWidth).arg(root.modeHeight)
    readonly property string name: Appearance.display.names[root.size] ?? ""

    signal triggered

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.display.tileHeight

    radius: Appearance.display.tileRounding
    color: root.selected ? Colours.accentMuted : Colours.elevated
    border.width: root.selected ? Appearance.display.tileBorder : 0
    border.color: Colours.accent

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.display.tilePadding
        anchors.rightMargin: Appearance.display.tilePadding

        StyledText {
            Layout.fillWidth: true

            text: root.name || root.size
            color: root.selected ? Colours.accent : Colours.textBright
            font.pixelSize: Appearance.display.tileNameSize
            font.bold: true
        }

        StyledText {
            visible: root.name !== ""
            text: root.size
            color: Colours.textMuted
            font.pixelSize: Appearance.display.tileSizeSize
        }
    }

    StateLayer {
        radius: root.radius

        onClicked: root.triggered()
    }
}
