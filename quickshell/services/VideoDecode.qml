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
    property var capabilities: ({})

    readonly property var software: root.streams.filter(stream => stream.kind === DecodeKind.cpu)
    readonly property bool dedicatedOnBattery: PowerSource.onBattery && GpuStats.cards.length > 1 && root.streams.some(stream => stream.kind === DecodeKind.gpu && GpuStats.cards.some(card => card.pci === stream.pci && card.dedicated))

    function onCard(pci: string): var {
        return root.streams.filter(stream => stream.kind === DecodeKind.gpu && stream.pci === pci);
    }

    function codecsOf(pci: string): var {
        return root.capabilities[pci] ?? null;
    }

    function support(key: string): string {
        const lists = Object.values(root.capabilities);

        if (lists.some(codecs => codecs !== null && codecs.includes(key)))
            return DecodeSupport.supported;
        if (lists.length > 0 && lists.every(codecs => codecs !== null))
            return DecodeSupport.unsupported;
        return DecodeSupport.unknown;
    }

    function applyCapabilities(payload: string): void {
        const next = {};

        payload.trim().split("\n").filter(line => line.length > 0).forEach(line => {
            const parts = line.split("\t");
            const codecs = parts[1] ?? "-";

            next[parts[0]] = codecs === "-" ? null : codecs === "none" ? [] : codecs.split(",");
        });
        root.capabilities = next;
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
                key: Appearance.hardware.codecKeys[parts[3]] ?? parts[3] ?? "",
                codec: root.codecLabel(parts[3] ?? ""),
                pci: parts[4] ?? "",
                load: Number(parts[5]) || 0
            };
        }).filter(stream => DecodeKind.values.includes(stream.kind)).sort((a, b) => b.load - a.load);
    }

    onActiveChanged: {
        if (root.active)
            capsProc.running = true;
        else
            root.streams = [];
    }

    Process {
        id: capsProc

        command: Commands.decodeCaps

        stdout: StdioCollector {
            onStreamFinished: root.applyCapabilities(text)
        }
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
