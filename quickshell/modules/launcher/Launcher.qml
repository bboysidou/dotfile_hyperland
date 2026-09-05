import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums

Scope {
    GlobalShortcut {
        appid: Ids.appid
        name: "launcher"

        onPressed: LauncherState.toggle()
    }

    IpcHandler {
        target: "launcher"

        function open(): string {
            LauncherState.show();
            return IpcStatus.open;
        }

        function close(): string {
            LauncherState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            LauncherState.toggle();
            return LauncherState.opened ? IpcStatus.open : IpcStatus.closed;
        }
    }
}
