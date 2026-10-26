import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.services

Scope {
    id: root

    Binding {
        target: Daemons
        property: "polling"
        value: SettingsState.opened
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "settings"

        onPressed: SettingsState.toggle()
    }

    IpcHandler {
        target: "settings"

        function open(): string {
            SettingsState.show();
            return IpcStatus.open;
        }

        function close(): string {
            SettingsState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            SettingsState.toggle();
            return SettingsState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function tab(name: string): string {
            SettingsState.tab = name;
            return SettingsState.tab;
        }

        function status(): string {
            return JSON.stringify(Daemons.states);
        }
    }
}
