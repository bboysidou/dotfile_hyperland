import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property var command: []
    property int interval: 0
    property bool polling: true

    signal received(string text)

    function poll(): void {
        proc.running = true;
    }

    Process {
        id: proc

        command: root.command

        stdout: StdioCollector {
            onStreamFinished: root.received(text)
        }
    }

    Timer {
        interval: root.interval
        running: root.polling && root.interval > 0
        repeat: true
        triggeredOnStart: true

        onTriggered: root.poll()
    }
}
