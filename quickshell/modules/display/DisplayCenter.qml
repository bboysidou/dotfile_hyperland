import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.hardware
import qs.modules.launcher
import qs.modules.updates

Scope {
    id: root

    GlobalShortcut {
        appid: Ids.appid
        name: "display"

        onPressed: DisplayState.toggle()
    }

    IpcHandler {
        target: "display"

        function open(): string {
            DisplayState.show();
            return IpcStatus.open;
        }

        function close(): string {
            DisplayState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            DisplayState.toggle();
            return DisplayState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function tab(name: string): string {
            DisplayState.tab = name;
            return DisplayState.tab;
        }
    }

    Connections {
        target: DisplayState

        function onOpenedChanged(): void {
            if (!DisplayState.opened)
                return;

            LauncherState.hide();
            ControlState.hide();
            UpdatesState.hide();
            HardwareState.hide();
            DashState.hide();
        }
    }

    Connections {
        target: ControlState

        function onOpenedChanged(): void {
            if (ControlState.opened)
                DisplayState.hide();
        }
    }

    Connections {
        target: HardwareState

        function onOpenedChanged(): void {
            if (HardwareState.opened)
                DisplayState.hide();
        }
    }

    Connections {
        target: LauncherState

        function onOpenedChanged(): void {
            if (LauncherState.opened)
                DisplayState.hide();
        }
    }
}
