import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.updates.components
import qs.services

RevealCard {
    id: root

    readonly property var config: Appearance.updates
    readonly property var tabs: [
        {
            key: root.config.tabRepo,
            icon: Icons.arch,
            label: root.config.tabLabelFormat.arg(root.config.labelRepo).arg(Updates.repo.length),
            accent: Colours.tabRepo
        },
        {
            key: root.config.tabAur,
            icon: Icons.updateAur,
            label: root.config.tabLabelFormat.arg(root.config.labelAur).arg(Updates.aur.length),
            accent: Colours.tabAur
        }
    ]

    function upgrade(): void {
        Launch.app(Terminal.command(Commands.updates));
        UpdatesState.hide();
    }

    outlineColour: tabBar.fill
    implicitWidth: Appearance.updates.width

    color: Colours.bar
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: Appearance.updates.scaleFrom
    transformOrigin: Item.TopRight

    visible: root.revealed || root.opacity > 0

    Fillet {
        anchors.right: parent.left
        anchors.top: parent.top

        origin: Corner.bottomLeft
    }

    Fillet {
        anchors.right: parent.left
        anchors.bottom: parent.bottom

        origin: Corner.topLeft
    }

    UpdatesHeader {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.updates.padding
        anchors.leftMargin: Appearance.updates.padding
        anchors.rightMargin: Appearance.updates.padding

        onUpgradeRequested: root.upgrade()
    }

    EmptyState {
        anchors.centerIn: parent

        visible: !Updates.available
        glyph: Icons.updates
        title: Appearance.updates.emptyTitle
        subtitle: Appearance.updates.emptySubtitle
    }

    SegmentBar {
        id: tabBar

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.updates.sectionSpacing
        anchors.leftMargin: Appearance.updates.padding
        anchors.rightMargin: Appearance.updates.padding

        visible: Updates.available
        current: UpdatesState.tab
        options: root.tabs

        onSelected: key => UpdatesState.tab = key
    }

    StackLayout {
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.updates.sectionSpacing
        anchors.leftMargin: Appearance.updates.padding
        anchors.rightMargin: Appearance.updates.padding
        anchors.bottomMargin: Appearance.updates.padding

        visible: Updates.available
        currentIndex: Math.max(0, root.tabs.findIndex(tab => tab.key === UpdatesState.tab))

        UpdateSection {
            placeholder: Appearance.updates.emptyRepo
            entries: Updates.repo
        }

        UpdateSection {
            placeholder: Appearance.updates.emptyAur
            entries: Updates.aur
        }
    }
}
