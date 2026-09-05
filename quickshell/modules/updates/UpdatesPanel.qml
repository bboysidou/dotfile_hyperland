import QtQuick
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.modules.updates.components
import qs.services

RevealCard {
    id: root

    readonly property real availableHeight: root.height - header.height - Appearance.updates.padding * 2 - Appearance.updates.sectionSpacing * 2
    readonly property real repoHeight: {
        const avail = root.availableHeight;
        if (repo.contentHeight + aur.contentHeight <= avail)
            return avail - aur.contentHeight;
        return Math.max(avail * Appearance.updates.repoMaxRatio, avail - aur.contentHeight);
    }

    function upgrade(): void {
        Quickshell.execDetached(Commands.updates);
        UpdatesState.hide();
    }

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

    UpdateSection {
        id: repo

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.updates.sectionSpacing
        anchors.leftMargin: Appearance.updates.padding
        anchors.rightMargin: Appearance.updates.padding

        visible: Updates.available
        height: root.repoHeight
        glyph: Icons.arch
        title: Appearance.updates.labelRepo
        placeholder: Appearance.updates.emptyRepo
        entries: Updates.repo

        Behavior on height {
            Anim {
                type: AnimType.emphasizedSmall
            }
        }
    }

    UpdateSection {
        id: aur

        anchors.top: repo.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.updates.sectionSpacing
        anchors.leftMargin: Appearance.updates.padding
        anchors.rightMargin: Appearance.updates.padding
        anchors.bottomMargin: Appearance.updates.padding

        visible: Updates.available
        glyph: Icons.updateAur
        title: Appearance.updates.labelAur
        placeholder: Appearance.updates.emptyAur
        entries: Updates.aur
    }
}
