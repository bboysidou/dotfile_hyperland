import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums

Scope {
    GlobalShortcut {
        appid: Ids.appid
        name: "screenshot"

        onPressed: ShotState.toggle()
    }

    IpcHandler {
        target: "screenshot"

        function open(): string {
            ShotState.show();
            return IpcStatus.open;
        }

        function close(): string {
            ShotState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            ShotState.toggle();
            return ShotState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function ocr(): string {
            ShotState.run(ShotAction.ocr);
            return IpcStatus.started;
        }
    }
}
