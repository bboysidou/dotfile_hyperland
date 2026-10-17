import Quickshell
import Quickshell.Io
import qs.core.enums

Scope {
    IpcHandler {
        target: "share"

        function pick(fifo: string, list: string, token: bool): string {
            ShareState.open(fifo, list, token);
            return IpcStatus.open;
        }

        function cancel(): string {
            ShareState.abandon();
            return IpcStatus.closed;
        }
    }
}
