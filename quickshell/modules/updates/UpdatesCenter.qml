import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.modules.controlcenter
import qs.services

Scope {
    id: root

    GlobalShortcut {
        appid: Ids.appid
        name: "updates"

        onPressed: UpdatesState.toggle()
    }

    IpcHandler {
        target: "updates"

        function open(): string {
            UpdatesState.show();
            return IpcStatus.open;
        }

        function close(): string {
            UpdatesState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            UpdatesState.toggle();
            return UpdatesState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function refresh(): string {
            Updates.refresh();
            return IpcStatus.started;
        }

        function status(): string {
            return `opened=${UpdatesState.opened} repo=${Updates.repo.length} aur=${Updates.aur.length}`;
        }
    }

    Connections {
        target: UpdatesState

        function onOpenedChanged(): void {
            if (UpdatesState.opened)
                ControlState.hide();
        }
    }

    Connections {
        target: ControlState

        function onOpenedChanged(): void {
            if (ControlState.opened)
                UpdatesState.hide();
        }
    }
}
