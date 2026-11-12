import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums

Scope {
    id: root

    GlobalShortcut {
        appid: Ids.appid
        name: "barlayout"

        onPressed: BarLayoutState.toggle()
    }

    IpcHandler {
        target: "barlayout"

        function open(): string {
            BarLayoutState.show();
            return IpcStatus.open;
        }

        function close(): string {
            BarLayoutState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            BarLayoutState.toggle();
            return BarLayoutState.opened ? IpcStatus.open : IpcStatus.closed;
        }
    }
}
