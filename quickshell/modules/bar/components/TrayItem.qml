import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    required property SystemTrayItem modelData
    required property var panel
    property string edge: BarEdge.top

    readonly property string label: root.modelData?.tooltipTitle || root.modelData?.title || root.modelData?.id || Appearance.bar.trayUnknownLabel

    function openMenu(): void {
        const origin = root.mapToItem(null, root.edge === BarEdge.left ? root.width : 0, root.edge === BarEdge.top ? root.height : 0);
        root.modelData?.display(root.panel, origin.x, origin.y);
    }

    implicitWidth: Appearance.bar.trayHitSize
    implicitHeight: Appearance.bar.trayHitSize

    color: pointer.containsMouse ? Colours.hover : "transparent"
    radius: Appearance.bar.trayHitRounding

    MouseArea {
        id: pointer

        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                root.modelData?.secondaryActivate();
            else if (event.button === Qt.RightButton || root.modelData?.onlyMenu)
                root.openMenu();
            else
                root.modelData?.activate();
        }
    }

    IconImage {
        anchors.centerIn: parent

        implicitSize: Appearance.bar.trayIconSize
        source: root.modelData?.icon ?? ""
        opacity: root.modelData?.status === Status.Passive ? Appearance.bar.trayPassiveOpacity : 1
    }

    Tooltip {
        readonly property real gap: Appearance.bar.trayTooltipGap

        x: root.edge === BarEdge.left ? root.width + gap : root.edge === BarEdge.right ? -width - gap : (root.width - width) / 2
        y: root.edge === BarEdge.top ? root.height + gap : root.edge === BarEdge.bottom ? -height - gap : (root.height - height) / 2

        text: root.label
        shown: pointer.containsMouse
    }
}
