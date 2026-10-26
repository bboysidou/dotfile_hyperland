import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.controlcenter.panels
import qs.modules.settings

Panel {
    id: root

    readonly property var config: Appearance.settings
    readonly property var tabs: [
        {
            key: root.config.tabGeneral,
            icon: Icons.settings,
            label: root.config.labelGeneralTab,
            accent: Colours.tabGeneral
        },
        {
            key: root.config.tabServices,
            icon: Icons.power,
            label: root.config.labelServicesTab,
            accent: Colours.tabServices
        }
    ]

    implicitWidth: root.config.width

    Keys.onEscapePressed: SettingsState.hide()

    ColumnLayout {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: Appearance.control.paneSpacing

        PanelHeader {
            glyph: Icons.settings
            title: root.config.title
        }

        SegmentBar {
            Layout.fillWidth: true

            current: SettingsState.tab
            options: root.tabs

            onSelected: key => SettingsState.tab = key
        }
    }

    StackLayout {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.control.paneSpacing

        currentIndex: Math.max(0, root.tabs.findIndex(tab => tab.key === SettingsState.tab))

        GeneralTab {}

        ServicesTab {
            accent: Colours.tabServices
        }
    }
}
