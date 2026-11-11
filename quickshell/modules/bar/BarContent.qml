import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

Item {
    id: root

    required property var panelWindow
    property string edge: BarEdge.top
    property string screenName: ""

    readonly property bool vertical: BarEdge.vertical(root.edge)

    StyledRect {
        anchors.fill: parent

        color: Colours.bar
        radius: Appearance.rounding.large

        BarSlot {
            id: leftSlot

            x: root.vertical ? (parent.width - width) / 2 : Appearance.bar.paddingSide
            y: root.vertical ? Appearance.bar.paddingSide : (parent.height - height) / 2

            edge: root.edge
            entries: Prefs.zoneEntries(root.screenName, BarZone.left)
            panelWindow: root.panelWindow
            mediaBudget: centreSlot.x - leftSlot.x - Appearance.bar.mediaGapMin
        }

        BarSlot {
            id: centreSlot

            readonly property real centred: (parent.height - height) / 2

            x: (parent.width - width) / 2
            y: root.vertical ? Math.max(leftSlot.y + leftSlot.height + Appearance.bar.slotGap, Math.min(centreSlot.centred, rightSlot.y - height - Appearance.bar.slotGap)) : centreSlot.centred

            edge: root.edge
            entries: Prefs.zoneEntries(root.screenName, BarZone.centre)
            panelWindow: root.panelWindow
            mediaBudget: parent.width - 2 * (Appearance.bar.paddingSide + Math.max(leftSlot.width, rightSlot.width) + Appearance.bar.mediaGapMin)
        }

        BarSlot {
            id: rightSlot

            x: root.vertical ? (parent.width - width) / 2 : parent.width - width - Appearance.bar.paddingSide
            y: root.vertical ? parent.height - height - Appearance.bar.paddingSide : (parent.height - height) / 2

            edge: root.edge
            entries: Prefs.zoneEntries(root.screenName, BarZone.right)
            panelWindow: root.panelWindow
            mediaBudget: parent.width - Appearance.bar.paddingSide - centreSlot.x - centreSlot.width - Appearance.bar.mediaGapMin
        }
    }
}
