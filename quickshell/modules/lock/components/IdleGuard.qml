import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import qs.core.config
import qs.core.constants
import qs.services

Scope {
    id: root

    property bool armed: true

    function rearm(): void {
        root.armed = false;
        rearmTimer.restart();
    }

    Timer {
        id: rearmTimer

        interval: Appearance.idle.rearmDelay

        onTriggered: root.armed = true
    }

    Connections {
        target: Idle

        function onLockSecondsChanged(): void {
            root.rearm();
        }

        function onScreenOffSecondsChanged(): void {
            root.rearm();
        }

        function onSuspendSecondsChanged(): void {
            root.rearm();
        }
    }

    IdleMonitor {
        enabled: root.armed && Idle.enabled && Idle.lockOn
        timeout: Idle.lockSeconds

        onIsIdleChanged: {
            if (isIdle)
                Lock.show();
        }
    }

    IdleMonitor {
        enabled: root.armed && Idle.enabled && Idle.screenOffOn
        timeout: Idle.screenOffSeconds

        onIsIdleChanged: Displays.setAllDpms(!isIdle)
    }

    IdleMonitor {
        enabled: root.armed && Idle.enabled && Idle.suspendOn && (UPower.onBattery || !Idle.batteryOnly)
        timeout: Idle.suspendSeconds

        onIsIdleChanged: {
            if (isIdle)
                Quickshell.execDetached(Commands.suspend);
        }
    }
}
