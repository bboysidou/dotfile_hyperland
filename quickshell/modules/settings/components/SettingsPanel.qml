import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.controlcenter.panels
import qs.modules.settings
import qs.services

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
        },
        {
            key: Appearance.errorLog.tabKey,
            icon: Icons.alert,
            label: ErrorLog.unseen > 0 ? Appearance.errorLog.tabTemplate.arg(Appearance.errorLog.labelTab).arg(ErrorLog.unseen) : Appearance.errorLog.labelTab,
            accent: Colours.tabErrors
        }
    ]
    readonly property bool watchingErrors: SettingsState.opened && SettingsState.tab === Appearance.errorLog.tabKey

    onWatchingErrorsChanged: ErrorLog.markSeen()

    outlineColour: tabBar.fill
    implicitWidth: root.config.width

    Keys.onEscapePressed: SettingsState.hide()
    Keys.onPressed: event => {
        const tabs = Nav.horizontal(event);
        if (tabs === 0 || !tabBar.visible)
            return;

        tabBar.step(tabs);
        event.accepted = true;
    }

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
            id: tabBar

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

        ErrorsTab {
            accent: Colours.tabErrors
        }
    }
}
