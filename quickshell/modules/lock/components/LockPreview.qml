pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.core.config
import qs.core.constants

Scope {
    id: root

    readonly property bool playing: loader.active

    function play(): void {
        loader.active = true;
    }

    LazyLoader {
        id: loader

        PanelWindow {
            id: window

            screen: Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) ?? null
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: Ids.lockPreviewNamespace
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            LockStage {
                id: stage

                anchors.fill: parent

                screen: window.screen
                focused: true

                onRevealed: hold.start()
                onExited: loader.active = false
            }

            Timer {
                id: hold

                interval: Appearance.lock.previewHold

                onTriggered: stage.leave()
            }
        }
    }
}
