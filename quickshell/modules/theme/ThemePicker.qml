import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.modules.launcher
import qs.services

Scope {
    readonly property string active: Theme.committed

    GlobalShortcut {
        appid: Ids.appid
        name: "theme-picker"

        onPressed: LauncherState.toggleThemes()
    }

    IpcHandler {
        target: "theme"

        function open(): string {
            LauncherState.showThemes();
            return IpcStatus.open;
        }

        function close(): string {
            LauncherState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            LauncherState.toggleThemes();
            return LauncherState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function set(name: string): string {
            Theme.set(name);
            return Theme.committed;
        }

        function next(): string {
            return Theme.cycle(1);
        }

        function get(): string {
            return Theme.committed;
        }

        function list(): string {
            return ThemeName.values.join("\n");
        }
    }
}
