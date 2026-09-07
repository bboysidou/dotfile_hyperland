import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.modules.controlcenter.panels
import qs.modules.bar
import qs.modules.dashboard
import qs.modules.launcher
import qs.modules.screenshot
import qs.modules.updates

PanelWindow {
    id: root

    required property var modelData

    readonly property alias inner: inner
    readonly property bool focused: Monitors.focused === root.screen.name
    readonly property bool grabbing: root.focused && BorderState.panelOpen
    readonly property bool covered: Monitors.covered(root.screen)

    property real revealed: root.covered ? 0 : 1

    screen: root.modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: root.grabbing ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.keyboardFocus: root.grabbing ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    mask: Region {
        Region {
            item: bar.visible ? bar : null
        }
        Region {
            item: launcher.revealed ? launcher : null
        }
        Region {
            item: audio.revealed ? audio : null
        }
        Region {
            item: network.revealed ? network : null
        }
        Region {
            item: bluetooth.revealed ? bluetooth : null
        }
        Region {
            item: notifications.revealed ? notifications : null
        }
        Region {
            item: dashboard.revealed ? dashboard : null
        }
        Region {
            item: updates.revealed ? updates : null
        }
    }

    Behavior on revealed {
        Anim {
            type: AnimType.standard
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.grabbing

        onCleared: {
            LauncherState.hide();
            ControlState.hide();
            DashState.hide();
        }
    }

    BorderFrame {
        anchors.fill: parent

        thickness: Appearance.border.thickness * root.revealed
        topThickness: Appearance.bar.height * root.revealed
        opacity: root.revealed
    }

    BarContent {
        id: bar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Appearance.border.thickness
        anchors.rightMargin: Appearance.border.thickness

        implicitHeight: Appearance.bar.height

        opacity: root.revealed
        visible: root.revealed > 0

        panelWindow: root
    }

    Item {
        id: inner

        anchors.fill: parent
        anchors.topMargin: Appearance.bar.height * root.revealed
        anchors.leftMargin: Appearance.border.thickness * root.revealed
        anchors.rightMargin: Appearance.border.thickness * root.revealed
        anchors.bottomMargin: Appearance.border.thickness * root.revealed

        Keys.onEscapePressed: BorderState.closeAll()

        LauncherPanel {
            id: launcher

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            revealed: root.focused && LauncherState.opened

            onDismissed: BorderState.closeAll()
        }

        ShotPanel {
            id: screenshot

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            revealed: root.focused && ShotState.opened

            onDismissed: BorderState.closeAll()
        }

        AudioPanel {
            id: audio

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            revealed: root.focused && ControlState.opened && ControlState.section === ControlSection.audio
        }

        NetworkPanel {
            id: network

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            revealed: root.focused && ControlState.opened && ControlState.section === ControlSection.network
        }

        BluetoothPanel {
            id: bluetooth

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            revealed: root.focused && ControlState.opened && ControlState.section === ControlSection.bluetooth
        }

        NotifPanel {
            id: notifications

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            revealed: root.focused && ControlState.opened && ControlState.section === ControlSection.notifications
        }

        UpdatesPanel {
            id: updates

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            revealed: root.focused && UpdatesState.opened
        }

        DashboardPanel {
            id: dashboard

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            revealed: root.focused && DashState.opened
        }
    }
}
