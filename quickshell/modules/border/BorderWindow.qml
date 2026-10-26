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
import qs.modules.settings
import qs.modules.settings.components
import qs.modules.share
import qs.modules.updates
import qs.services

PanelWindow {
    id: root

    required property var modelData

    readonly property alias inner: inner
    readonly property bool focused: Monitors.focused === root.screen.name
    readonly property bool grabbing: root.focused && BorderState.panelOpen
    readonly property bool covered: Monitors.covered(root.screen)
    readonly property real rightInset: [audio, network, bluetooth, notifications, power, updates, hardware, settings].find(slot => slot.open)?.item?.width ?? 0
    readonly property Item openPanel: [launcher, screenshot, share, audio, network, bluetooth, notifications, power, updates, hardware, display, settings, dashboard].find(slot => slot.open)?.item ?? null

    property real revealed: root.covered ? 0 : 1
    property real outline: root.openPanel !== null && Prefs.panelOutline !== OutlineMode.off ? 1 : 0
    property color outlineColour: Colours.accent

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
            item: settings.item?.revealed ? settings.item : null
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

    Binding {
        when: root.openPanel !== null
        target: root
        property: "outlineColour"
        value: Prefs.panelOutline === OutlineMode.grey ? Colours.outlineMuted : root.openPanel?.outlineColour ?? Colours.accent
        restoreMode: Binding.RestoreNone
    }

    Behavior on revealed {
        Anim {
            type: AnimType.standard
        }
    }

    Behavior on outline {
        Anim {
            type: AnimType.fastEffects
        }
    }

    Behavior on outlineColour {
        CAnim {
            type: AnimType.fastEffects
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
            SettingsState.hide();
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

    Item {
        id: silhouette

        anchors.fill: parent

        layer.enabled: root.outline > 0
        layer.smooth: true
        layer.effect: ShaderEffect {
            readonly property vector2d texel: Qt.vector2d(1 / Math.max(1, width), 1 / Math.max(1, height))
            readonly property color outlineColour: root.outlineColour
            readonly property real stroke: Appearance.border.outline
            readonly property real strength: root.outline
            readonly property real solidFrom: Appearance.border.outlineSolidFrom
            readonly property real solidTo: Appearance.border.outlineSolidTo

            fragmentShader: Quickshell.shellPath(Appearance.border.outlineShader)
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
                id: settings

                open: root.focused && SettingsState.opened

                SettingsPanel {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
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
}
