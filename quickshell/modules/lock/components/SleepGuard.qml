import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.services

Scope {
    id: root

    required property bool secure

    property bool sleeping: false

    readonly property bool ready: root.sleeping && root.secure && Lock.locked

    function prepare(starting: bool): void {
        root.sleeping = starting;

        if (starting)
            Lock.show();
    }

    Process {
        running: !root.ready

        command: Commands.sleepInhibitor
    }

    Process {
        id: monitor

        running: true

        command: Commands.sleepMonitor

        stdout: SplitParser {
            onRead: data => {
                if (data.includes(Commands.sleepSignal))
                    root.prepare(data.includes(Commands.sleepStarting));
            }
        }

        onExited: retry.restart()
    }

    Timer {
        id: retry

        interval: Appearance.lock.sleepMonitorRetry

        onTriggered: monitor.running = true
    }
}
