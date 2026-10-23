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
import qs.modules.display
import qs.modules.display.components
import qs.modules.hardware
import qs.modules.launcher
import qs.modules.screenshot
import qs.modules.share
import qs.modules.updates

PanelWindow {
    id: root

    required property var modelData

    readonly property alias inner: inner
    readonly property bool focused: Monitors.focused === root.screen.name
    readonly property bool grabbing: root.focused && BorderState.panelOpen
    readonly property bool covered: Monitors.covered(root.screen)
    readonly property real rightInset: [audio, network, bluetooth, notifications, power, updates, hardware].find(slot => slot.open)?.item?.width ?? 0

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

    Binding {
        when: root.focused
        target: BorderState
        property: "rightInset"
        value: root.rightInset
        restoreMode: Binding.RestoreNone
    }

    mask: Region {
        Region {
            item: scrim.enabled ? scrim : null
        }
        Region {
            item: bar.visible ? bar : null
        }
        Region {
            item: launcher.item?.revealed ? launcher.item : null
        }
        Region {
            item: audio.item?.revealed ? audio.item : null
        }
        Region {
            item: network.item?.revealed ? network.item : null
        }
        Region {
            item: bluetooth.item?.revealed ? bluetooth.item : null
        }
        Region {
            item: notifications.item?.revealed ? notifications.item : null
        }
        Region {
            item: power.item?.revealed ? power.item : null
        }
        Region {
            item: display.item?.revealed ? display.item : null
        }
        Region {
            item: dashboard.item?.revealed ? dashboard.item : null
        }
        Region {
            item: updates.item?.revealed ? updates.item : null
        }
        Region {
            item: hardware.item?.revealed ? hardware.item : null
        }
        Region {
            item: share.item?.revealed ? share.item : null
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
            HardwareState.hide();
            ShareState.dismiss();
        }
    }

    MouseArea {
        id: scrim

        anchors.fill: parent

        enabled: root.grabbing
        acceptedButtons: Qt.AllButtons

        onPressed: BorderState.closeAll()
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

        PanelSlot {
            id: launcher

            open: root.focused && LauncherState.opened

            LauncherPanel {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                onDismissed: BorderState.closeAll()
            }
        }

        PanelSlot {
            id: screenshot

            open: root.focused && ShotState.opened

            ShotPanel {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                onDismissed: BorderState.closeAll()
            }
        }

        PanelSlot {
            id: share

            open: root.focused && ShareState.opened

            SharePanel {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        PanelSlot {
            id: audio

            open: root.focused && ControlState.opened && ControlState.section === ControlSection.audio

            AudioPanel {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        PanelSlot {
            id: network

            open: root.focused && ControlState.opened && ControlState.section === ControlSection.network

            NetworkPanel {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        PanelSlot {
            id: bluetooth

            open: root.focused && ControlState.opened && ControlState.section === ControlSection.bluetooth

            BluetoothPanel {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        PanelSlot {
            id: notifications

            open: root.focused && ControlState.opened && ControlState.section === ControlSection.notifications

            NotifPanel {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        PanelSlot {
            id: power

            open: root.focused && ControlState.opened && ControlState.section === ControlSection.power

            PowerPanel {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        PanelSlot {
            id: updates

            open: root.focused && UpdatesState.opened

            UpdatesPanel {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        PanelSlot {
            id: hardware

            open: root.focused && HardwareState.opened

            HardwarePanel {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        PanelSlot {
            id: display

            open: root.focused && DisplayState.opened

            DisplayPanel {
                anchors.centerIn: parent
            }
        }

        PanelSlot {
            id: dashboard

            open: root.focused && DashState.opened

            DashboardPanel {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
