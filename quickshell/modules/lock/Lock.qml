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
import qs.modules.lock.components
import qs.services

Scope {
    id: root

    GlobalShortcut {
        appid: Ids.appid
        name: "lock"

        onPressed: Lock.show()
    }

    IpcHandler {
        target: "lock"

        function lock(): string {
            Lock.show();
            return IpcStatus.locked;
        }

        function status(): string {
            return Lock.locked ? "locked" : "unlocked";
        }

        function state(): string {
            return JSON.stringify({
                locked: Lock.locked,
                failures: Lock.failures,
                cooldown: Lock.cooldown,
                coolingDown: Lock.coolingDown,
                focused: Lock.focused
            });
        }
    }

    WlSessionLock {
        id: session

        locked: Lock.locked

        WlSessionLockSurface {
            id: surface

            color: "transparent"

            MouseArea {
                anchors.fill: parent

                onPressed: keys.forceActiveFocus()
            }

            Item {
                id: content

                anchors.fill: parent

                opacity: 0

                Anim {
                    target: content
                    property: "opacity"
                    to: 1
                    type: Appearance.lock.fadeInType
                    running: true
                }

                SequentialAnimation {
                    id: exit

                    Anim {
                        target: content
                        property: "opacity"
                        to: 0
                        type: Appearance.lock.fadeOutType
                    }
                    ScriptAction {
                        script: Lock.release()
                    }
                }

                Connections {
                    target: Lock

                    function onUnlockingChanged(): void {
                        if (Lock.unlocking)
                            exit.start();
                    }
                }

                Image {
                    id: shot

                    anchors.fill: parent

                    source: Wallpaper.current ? `file://${Wallpaper.current}` : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize: Qt.size(surface.width, surface.height)
                    visible: false
                }

                MultiEffect {
                    anchors.fill: parent

                    source: shot
                    blurEnabled: true
                    blur: Appearance.lock.blur
                    blurMax: Appearance.lock.blurMax
                    autoPaddingEnabled: false
                }

                Rectangle {
                    anchors.fill: parent

                    color: Colours.surface
                    opacity: Appearance.lock.backgroundDim
                }

                Identity {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: Appearance.lock.edgeMargin
                    anchors.leftMargin: Appearance.lock.edgeMargin
                }

                Column {
                    anchors.centerIn: parent

                    spacing: Appearance.lock.fieldTopMargin

                    Clock {
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Password {
                        anchors.horizontalCenter: parent.horizontalCenter

                        focused: keys.activeFocus
                    }
                }

                Connectivity {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.bottomMargin: Appearance.lock.edgeMargin
                    anchors.leftMargin: Appearance.lock.edgeMargin
                }

                MediaChip {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: Appearance.lock.edgeMargin
                }

                Batteries {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.bottomMargin: Appearance.lock.edgeMargin
                    anchors.rightMargin: Appearance.lock.edgeMargin
                }
            }

            KeyBuffer {
                id: keys

                anchors.fill: parent

                onActiveFocusChanged: Lock.focusHolders += keys.activeFocus ? 1 : -1

                onAccepted: Lock.authenticate()
                onCancelled: Lock.reset()
                onBackspaced: Lock.backspace()
                onAppended: text => Lock.append(text)
            }

            Connections {
                target: Lock

                function onLockedChanged(): void {
                    if (Lock.locked)
                        keys.forceActiveFocus();
                }

                function onRecoveringChanged(): void {
                    if (!Lock.recovering)
                        keys.forceActiveFocus();
                }
            }

            Timer {
                running: Lock.locked && surface.visible && !keys.activeFocus
                interval: Appearance.lock.focusPollInterval
                repeat: true

                onTriggered: keys.forceActiveFocus()
            }

            Component.onCompleted: keys.forceActiveFocus()

            onVisibleChanged: {
                if (surface.visible)
                    keys.forceActiveFocus();
            }
        }
    }
}
