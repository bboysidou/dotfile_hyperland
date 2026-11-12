pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.components

Singleton {
    id: root

    readonly property string device: "tpacpi::kbd_backlight"
    property int level: 0
    property int maximum: 0
    property int pending: -1
    property int resumeLevel: -1
    readonly property bool available: root.maximum > 0

    function step(delta: int): void {
        if (!root.available)
            return;
        root.setLevel(root.level + delta);
    }

    function setLevel(value: int): void {
        if (!root.available)
            return;
        root.pending = Math.max(0, Math.min(root.maximum, value));
        root.level = root.pending;
        root.flush();
    }

    function setScreenOff(off: bool): void {
        if (off) {
            if (!root.available || root.resumeLevel >= 0)
                return;
            root.resumeLevel = root.level;
            root.setLevel(0);
        } else if (root.resumeLevel >= 0) {
            const previous = root.resumeLevel;
            root.resumeLevel = -1;
            root.setLevel(previous);
        }
    }

    function flush(): void {
        if (adjust.running || root.pending < 0)
            return;
        adjust.command = ["brightnessctl", "-d", root.device, "-q", "set", String(root.pending)];
        root.pending = -1;
        adjust.running = true;
    }

    Process {
        id: adjust

        onExited: {
            if (root.pending >= 0)
                root.flush();
            else
                poller.poll();
        }
    }

    Poller {
        id: poller

        interval: 2000
        command: ["brightnessctl", "-d", root.device, "-m", "info"]

        onReceived: text => {
            const fields = text.trim().split(",");
            const current = Number(fields[2]);
            const maximum = Number(fields[4]);
            root.maximum = fields.length === 5 && isFinite(maximum) && maximum > 0 ? maximum : 0;
            if (root.available && isFinite(current) && !adjust.running && root.pending < 0)
                root.level = current;
        }
    }
}
