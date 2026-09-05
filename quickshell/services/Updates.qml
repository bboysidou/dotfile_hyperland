pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.components
import qs.core.config

Singleton {
    id: root

    property int count: 0

    readonly property bool available: count > 0

    function apply(payload: string): void {
        const counts = payload.trim().split("\n").map(line => Number(line.trim()));
        root.count = counts.reduce((total, value) => total + (isFinite(value) ? value : 0), 0);
    }

    Poller {
        command: ["sh", "-c", `timeout ${Appearance.bar.updatesTimeout} checkupdates 2>/dev/null | wc -l; timeout ${Appearance.bar.updatesTimeout} yay -Qua 2>/dev/null | wc -l`]
        interval: Appearance.bar.updatesPollInterval

        onReceived: text => root.apply(text)
    }
}
