pragma Singleton

import Quickshell
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.hardware
import qs.modules.launcher
import qs.modules.screenshot
import qs.modules.share
import qs.modules.updates

Singleton {
    readonly property bool panelOpen: LauncherState.opened || ControlState.opened || UpdatesState.opened || HardwareState.opened || DashState.pinned || ShotState.opened || ShareState.opened

    function closeAll(): void {
        LauncherState.hide();
        ShotState.hide();
        ShareState.dismiss();
        ControlState.hide();
        UpdatesState.hide();
        HardwareState.hide();
        DashState.hide();
    }
}
