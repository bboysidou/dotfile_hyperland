import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import qs.core.constants
import qs.services

Scope {
    IdleMonitor {
        enabled: Idle.enabled && Idle.lockOn
        timeout: Idle.lockSeconds

        onIsIdleChanged: {
            if (isIdle)
                Lock.show();
        }
    }

    IdleMonitor {
        enabled: Idle.enabled && Idle.screenOffOn
        timeout: Idle.screenOffSeconds

        onIsIdleChanged: Displays.setAllDpms(!isIdle)
    }

    IdleMonitor {
        enabled: Idle.enabled && Idle.suspendOn && (UPower.onBattery || !Idle.batteryOnly)
        timeout: Idle.suspendSeconds

        onIsIdleChanged: {
            if (isIdle)
                Quickshell.execDetached(Commands.suspend);
        }
    }
}
