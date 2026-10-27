pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums

Singleton {
    id: root

    property bool active: false
    property var streams: []

    readonly property var software: root.streams.filter(stream => stream.kind === DecodeKind.cpu)

    function onCard(pci: string): var {
        return root.streams.filter(stream => stream.kind === DecodeKind.gpu && stream.pci === pci);
    }

    function codecLabel(codec: string): string {
        if (codec === "" || codec === "-")
            return Appearance.hardware.codecUnknown;

        return Appearance.hardware.codecLabels[codec] ?? codec.toUpperCase();
    }

    function apply(payload: string): void {
        root.streams = payload.trim().split("\n").filter(line => line.length > 0).map(line => {
            const parts = line.split("\t");

            return {
                kind: parts[0],
                pid: parts[1],
                app: parts[2] ?? "",
                codec: root.codecLabel(parts[3] ?? ""),
                pci: parts[4] ?? "",
                load: Number(parts[5]) || 0
            };
        }).filter(stream => DecodeKind.values.includes(stream.kind)).sort((a, b) => b.load - a.load);
    }

    onActiveChanged: {
        if (!root.active)
            root.streams = [];
    }

    Process {
        id: scanProc

        command: Commands.decode

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.active)
                    root.apply(text);
            }
        }
    }

    Timer {
        interval: Appearance.hardware.decodePollInterval
        running: root.active
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!scanProc.running)
                scanProc.running = true;
        }
    }
}
