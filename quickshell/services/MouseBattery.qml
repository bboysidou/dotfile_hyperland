pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.components
import qs.core.config
import qs.core.constants

Singleton {
    id: root

    property bool available: false
    property int percent: 0
    property string state: ""

    readonly property bool charging: state === "RECHARGING"

    property int lastPercent: -1

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
        root.warnOnCrossing();
        root.lastPercent = root.percent;
    }

    function warnOnCrossing(): void {
        if (root.charging || root.lastPercent <= Prefs.mouseWarn || root.percent > Prefs.mouseWarn)
            return;
        notifier.command = ["notify-send", "-a", Ids.appid, "-i", Appearance.bar.mouseLowIcon, Appearance.bar.mouseLowSummary, Appearance.bar.mouseLowBody.arg(root.percent)];
        notifier.running = true;
    }

    Process {
        id: notifier
    }

    Poller {
        command: ["solaar", "show"]
        interval: Appearance.bar.mousePollInterval

        onReceived: text => root.apply(text)
    }
}
