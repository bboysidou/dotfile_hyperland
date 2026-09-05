pragma Singleton

import Quickshell
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.launcher
import qs.modules.screenshot

Singleton {
    readonly property bool panelOpen: LauncherState.opened || ControlState.opened || DashState.pinned || ShotState.opened

    function closeAll(): void {
        LauncherState.hide();
        ShotState.hide();
        ControlState.hide();
        DashState.hide();
    }
}
