pragma ComponentBehavior: Bound

import QtQuick
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

    GlobalShortcut {
        appid: Ids.appid
        name: "lid"

        onPressed: {
            if (!Lock.locked && !Quickshell.screens.some(screen => !LowPower.internal(screen.name)))
                Lock.show();
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): string {
            Lock.show();
            return IpcStatus.locked;
        }

        function preview(): string {
            if (Lock.locked || introPreview.playing)
                return IpcStatus.busy;

            introPreview.play();
            return IpcStatus.started;
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

    LockPreview {
        id: introPreview
    }

    SleepGuard {
        secure: session.secure
    }

    IdleGuard {}

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

            LockStage {
                id: stage

                anchors.fill: parent

                screen: surface.screen
                focused: keys.activeFocus

                onExited: Lock.release()

                Connections {
                    target: Lock

                    function onUnlockingChanged(): void {
                        if (Lock.unlocking)
                            stage.leave();
                    }
                }
            }

            KeyBuffer {
                id: keys

                anchors.fill: parent

                onActiveFocusChanged: Lock.focusHolders += keys.activeFocus ? 1 : -1

                onAccepted: Lock.authenticate()
                onCancelled: Lock.reset()
                onBackspaced: Lock.backspace()
                onCleared: Lock.clear()
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
