import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property SystemTrayItem modelData
    required property var panel

    readonly property string label: root.modelData?.tooltipTitle || root.modelData?.title || root.modelData?.id || Appearance.bar.trayUnknownLabel

    function openMenu(): void {
        const origin = root.mapToItem(null, 0, root.height);
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
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.bar.trayTooltipGap

        text: root.label
        shown: pointer.containsMouse
    }
}
