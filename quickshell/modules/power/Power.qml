pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.power.components
import qs.services

Scope {
    id: root

    GlobalShortcut {
        appid: Ids.appid
        name: "power"

        onPressed: PowerState.toggle()
    }

    IpcHandler {
        target: "power"

        function open(): string {
            PowerState.show();
            return IpcStatus.open;
        }

        function close(): string {
            PowerState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            PowerState.toggle();
            return PowerState.opened ? IpcStatus.open : IpcStatus.closed;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData

            readonly property bool active: PowerState.opened
            readonly property bool primary: PowerState.screen === panel.modelData.name

            screen: panel.modelData
            color: "transparent"
            visible: panel.active || content.opacity > 0

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: panel.primary ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            onVisibleChanged: {
                if (panel.visible && panel.primary)
                    keys.forceActiveFocus();
            }

            Item {
                id: content

                anchors.fill: parent

                opacity: panel.active ? 1 : 0

                Behavior on opacity {
                    Anim {
                        type: panel.active ? Appearance.power.fadeInType : Appearance.power.fadeOutType
                    }
                }

                Image {
                    id: shot

                    anchors.fill: parent

                    source: Wallpaper.current ? `file://${Wallpaper.current}` : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize: Qt.size(panel.width, panel.height)
                    visible: false
                }

                MultiEffect {
                    anchors.fill: parent

                    source: shot
                    blurEnabled: true
                    blur: Appearance.power.blur
                    blurMax: Appearance.power.blurMax
                    autoPaddingEnabled: false
                }

                Rectangle {
                    anchors.fill: parent

                    color: Colours.surface
                    opacity: Appearance.power.backgroundDim
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: PowerState.hide()
                }

                Column {
                    anchors.centerIn: parent

                    spacing: Appearance.power.sectionSpacing
                    visible: panel.primary

                    PowerHeader {
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter

                        spacing: Appearance.power.tileSpacing

                        Repeater {
                            model: PowerState.actions

                            PowerTile {
                                required property var modelData
                                required property int index

                                icon: modelData.icon
                                label: modelData.label
                                selected: PowerState.index === index

                                onHovered: PowerState.select(index)
                                onActivated: PowerState.activate()
                            }
                        }
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: Appearance.power.hint
                        color: Colours.textMuted
                        opacity: Appearance.power.hintOpacity
                        font.pixelSize: Appearance.power.hintSize
                    }
                }
            }

            Item {
                id: keys

                anchors.fill: parent

                focus: panel.primary

                Keys.onPressed: event => {
                    const delta = Nav.horizontal(event);

                    if (event.key === Qt.Key_Escape)
                        PowerState.hide();
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        PowerState.activate();
                    else if (delta !== 0)
                        PowerState.step(delta);
                    else
                        PowerState.activateKey(event.text);

                    event.accepted = true;
                }
            }
        }
    }
}
