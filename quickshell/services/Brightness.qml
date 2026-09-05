pragma Singleton

import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants

Singleton {
    id: root

    property bool available: false
    property int percent: 0

    function apply(payload: string): void {
        const value = Number(payload.trim());

        root.available = isFinite(value) && value >= 0;
        root.percent = root.available ? value : 0;
    }

    function step(delta: int): void {
        if (!root.available)
            return;

        adjust.command = ["sh", "-c", Commands.brightnessSet.arg(delta)];
        adjust.running = true;
    }

    Process {
        id: adjust

        onExited: query.running = true
    }

    Process {
        id: query

        running: true
        command: ["sh", "-c", Commands.brightnessQuery]

        stdout: StdioCollector {
            onStreamFinished: root.apply(text)
        }
    }
}
