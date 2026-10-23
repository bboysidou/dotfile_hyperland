pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property bool active: false
    property string span: Appearance.batteryTab.defaultSpan
    property var charge: []
    property var rate: []
    property real cpuWatts: -1

    readonly property var config: Appearance.batteryTab
    readonly property int seconds: (root.config.spans.find(entry => entry.key === root.span) ?? root.config.spans[0]).seconds
    readonly property bool polling: root.active && Battery.upowerPath !== ""

    function points(text: string): var {
        try {
            const rows = JSON.parse(text).data?.[0] ?? [];
            return rows.filter(row => row[2] !== 0).sort((first, second) => first[0] - second[0]).map(row => Math.abs(row[1]));
        } catch (parseError) {
            return [];
        }
    }

    function command(kind: string): var {
        return ["sh", "-c", Commands.upowerHistory, "sh", Battery.upowerPath, kind, String(root.seconds), String(root.config.historyPoints)];
    }

    onSpanChanged: {
        if (!root.polling)
            return;
        chargePoller.poll();
        ratePoller.poll();
    }

    Poller {
        id: chargePoller

        command: root.command(root.config.historyCharge)
        interval: root.config.historyInterval
        polling: root.polling

        onReceived: text => root.charge = root.points(text)
    }

    Poller {
        id: ratePoller

        command: root.command(root.config.historyRate)
        interval: root.config.historyInterval
        polling: root.polling

        onReceived: text => root.rate = root.points(text)
    }

    Timer {
        interval: root.config.splitInterval
        running: root.active
        repeat: true
        triggeredOnStart: true

        onTriggered: cpu.reload()
    }

    FileView {
        id: cpu

        path: Paths.cpuPower
        printErrors: false

        onLoaded: root.cpuWatts = Number(text().trim())
        onLoadFailed: root.cpuWatts = -1
    }
}
