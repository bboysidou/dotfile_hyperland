import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display.components

Panel {
    id: root

    readonly property var config: Appearance.idle

    ColumnLayout {
        anchors.fill: parent

        spacing: Appearance.control.paneSpacing

        PanelHeader {
            glyph: Icons.sleep
            title: root.config.panelTitle
        }

        IdleTab {
            labelWidth: root.config.panelLabelWidth
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
