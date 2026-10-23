pragma Singleton

import QtQuick
import Quickshell
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.display
import qs.modules.hardware
import qs.modules.launcher
import qs.modules.screenshot
import qs.modules.share
import qs.modules.updates

Singleton {
    id: root

    readonly property bool sideOpen: LauncherState.opened || ControlState.opened || UpdatesState.opened || HardwareState.opened || ShotState.opened || ShareState.opened || DisplayState.opened
    readonly property bool panelOpen: root.sideOpen || DashState.pinned

    function closeExcept(keep: QtObject): void {
        if (keep !== LauncherState && LauncherState.opened)
            LauncherState.hide();
        if (keep !== ShotState && ShotState.opened)
            ShotState.hide();
        if (keep !== ShareState)
            ShareState.dismiss();
        if (keep !== ControlState && ControlState.opened)
            ControlState.hide();
        if (keep !== UpdatesState && UpdatesState.opened)
            UpdatesState.hide();
        if (keep !== HardwareState && HardwareState.opened)
            HardwareState.hide();
        if (keep !== DashState && DashState.opened)
            DashState.hide();
        if (keep !== DisplayState && DisplayState.opened)
            DisplayState.hide();
    }

    function closeAll(): void {
        root.closeExcept(null);
    }

    Binding {
        target: DashState
        property: "blocked"
        value: root.sideOpen
    }

    Connections {
        target: LauncherState

        function onOpenedChanged(): void {
            if (LauncherState.opened)
                root.closeExcept(LauncherState);
        }
    }

    Connections {
        target: ShotState

        function onOpenedChanged(): void {
            if (ShotState.opened)
                root.closeExcept(ShotState);
        }
    }

    Connections {
        target: ShareState

        function onOpenedChanged(): void {
            if (ShareState.opened)
                root.closeExcept(ShareState);
        }
    }

    Connections {
        target: ControlState

        function onOpenedChanged(): void {
            if (ControlState.opened)
                root.closeExcept(ControlState);
        }
    }

    Connections {
        target: UpdatesState

        function onOpenedChanged(): void {
            if (UpdatesState.opened)
                root.closeExcept(UpdatesState);
        }
    }

    Connections {
        target: HardwareState

        function onOpenedChanged(): void {
            if (HardwareState.opened)
                root.closeExcept(HardwareState);
        }
    }

    Connections {
        target: DashState

        function onPinnedChanged(): void {
            if (DashState.pinned)
                root.closeExcept(DashState);
        }
    }

    Connections {
        target: DisplayState

        function onOpenedChanged(): void {
            if (DisplayState.opened)
                root.closeExcept(DisplayState);
        }
    }
}
