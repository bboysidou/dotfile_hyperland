import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import qs.core.config
import qs.core.constants
import qs.services

Scope {
    id: root

    readonly property bool enabled: Quickshell.env(Appearance.lock.idleEnv) === Appearance.lock.idleEnabled

    IdleMonitor {
        enabled: root.enabled
        timeout: Appearance.lock.idleLockSeconds

        onIsIdleChanged: {
            if (isIdle)
                Lock.show();
        }
    }

    IdleMonitor {
        enabled: root.enabled
        timeout: Appearance.lock.idleScreenOffSeconds

        onIsIdleChanged: Displays.setAllDpms(!isIdle)
    }

    IdleMonitor {
        enabled: root.enabled && UPower.onBattery
        timeout: Appearance.lock.idleSuspendSeconds

        onIsIdleChanged: {
            if (isIdle)
                Quickshell.execDetached(Commands.suspend);
        }
    }
}
