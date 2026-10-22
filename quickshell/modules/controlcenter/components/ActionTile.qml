import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string glyph

    signal triggered

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.powerPanel.actionHeight

    radius: Appearance.powerPanel.actionRounding
    color: Colours.elevated

    Icon {
        anchors.centerIn: parent

        text: root.glyph
        color: Colours.textBright
        font.pixelSize: Appearance.powerPanel.actionIconSize
    }

    StateLayer {
        radius: root.radius

        onClicked: root.triggered()
    }
}
