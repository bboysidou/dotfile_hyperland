import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.modules.launcher

Scope {
    GlobalShortcut {
        appid: Ids.appid
        name: "wallpaper-picker"

        onPressed: LauncherState.toggleWallpapers()
    }

    IpcHandler {
        target: "wallpaper"

        function open(): string {
            LauncherState.showWallpapers();
            return IpcStatus.open;
        }

        function close(): string {
            LauncherState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            LauncherState.toggleWallpapers();
            return LauncherState.opened ? IpcStatus.open : IpcStatus.closed;
        }
    }
}
