pragma Singleton

import Quickshell
import qs.core.components
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property real seconds: 0

    readonly property string text: Fmt.uptime(root.seconds)

    function refresh(): void {
        poller.poll();
    }

    function apply(payload: string): void {
        const value = Number(payload.trim().split(" ")[0]);
        root.seconds = isFinite(value) ? value : 0;
    }

    Poller {
        id: poller

        command: Commands.uptime

        onReceived: text => root.apply(text)
    }
}
