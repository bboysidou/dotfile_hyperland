import Quickshell
import Quickshell.Io
import qs.core.enums

Scope {
    IpcHandler {
        target: "share"

        function pick(fifo: string, list: string, workspaces: string, token: bool): string {
            ShareState.open(fifo, list, workspaces, token);
            return IpcStatus.open;
        }

        function cancel(): string {
            ShareState.abandon();
            return IpcStatus.closed;
        }
    }
}
