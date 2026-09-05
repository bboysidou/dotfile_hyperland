pragma Singleton

import Quickshell
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.launcher
import qs.modules.screenshot
import qs.modules.updates

Singleton {
    readonly property bool panelOpen: LauncherState.opened || ControlState.opened || UpdatesState.opened || DashState.pinned || ShotState.opened

    function closeAll(): void {
        LauncherState.hide();
        ShotState.hide();
        ControlState.hide();
        UpdatesState.hide();
        DashState.hide();
    }
}
