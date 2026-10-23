pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums

Singleton {
    id: root

    property string backend: BrightnessBackend.none
    property int percent: 0
    property int pending: -1

    readonly property bool available: root.backend !== BrightnessBackend.none

    function apply(payload: string): void {
        const [backend, raw] = payload.trim().split(" ");
        const value = Number(raw);
        const known = (backend === BrightnessBackend.backlight || backend === BrightnessBackend.ddc) && isFinite(value) && value >= 0;

        root.backend = known ? backend : BrightnessBackend.none;
        if (known && root.pending === -1 && !debounce.running && !adjust.running)
            root.percent = value;
    }

    function setPercent(value: int): void {
        if (!root.available)
            return;

        root.percent = Math.max(Appearance.powerPanel.brightnessMin, Math.min(Appearance.scale.percent, value));
        root.pending = root.percent;
        debounce.restart();
    }

    function flush(): void {
        if (root.pending === -1 || adjust.running)
            return;

        const template = root.backend === BrightnessBackend.ddc ? Commands.brightnessDdcSet : Commands.brightnessSet;
        adjust.command = ["sh", "-c", template.arg(root.pending)];
        root.pending = -1;
        adjust.running = true;
    }

    Timer {
        id: debounce

        interval: root.backend === BrightnessBackend.ddc ? Appearance.powerPanel.ddcDebounce : Appearance.powerPanel.backlightDebounce

        onTriggered: root.flush()
    }

    Process {
        id: adjust

        onExited: {
            if (root.pending !== -1)
                root.flush();
        }
    }

    Timer {
        id: refresh

        interval: Appearance.powerPanel.backlightRefresh

        onTriggered: query.running = true
    }

    Process {
        running: root.backend === BrightnessBackend.backlight
        command: Commands.backlightEvents

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                if (data.includes(Commands.backlightChange))
                    refresh.restart();
            }
        }
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
