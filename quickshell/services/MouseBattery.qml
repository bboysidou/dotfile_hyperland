pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.components
import qs.core.config

Singleton {
    id: root

    property bool available: false
    property int percent: 0
    property string state: ""

    readonly property bool charging: state === "RECHARGING"

    function apply(payload: string): void {
        const capacity = payload.match(/Battery: (\d+)%/);
        if (!capacity) {
            root.available = false;
            return;
        }

        const status = payload.match(/BatteryStatus\.([A-Z_]+)/);

        root.percent = Number(capacity[1]);
        root.state = status ? status[1] : "";
        root.available = true;
    }

    Poller {
        command: ["solaar", "show"]
        interval: Appearance.bar.mousePollInterval

        onReceived: text => root.apply(text)
    }
}
