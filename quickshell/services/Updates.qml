pragma Singleton

import QtQuick
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants

Singleton {
    id: root

    property var repo: []
    property var aur: []
    property bool repoPending: false
    property bool aurPending: false

    readonly property int count: root.repo.length + root.aur.length
    readonly property bool available: root.count > 0
    readonly property bool refreshing: root.repoPending || root.aurPending

    function parse(payload: string): var {
        return payload.trim().split("\n").map(line => line.trim().split(/\s+/)).filter(parts => parts.length >= 4).map(parts => ({
                    name: parts[0],
                    from: parts[1],
                    to: parts[3]
                }));
    }

    function refresh(): void {
        root.repoPending = true;
        root.aurPending = true;
        repoPoller.poll();
        aurPoller.poll();
    }

    Poller {
        id: repoPoller

        command: ["sh", "-c", Commands.repoUpdates.arg(Appearance.updates.timeout)]
        interval: Appearance.updates.pollInterval

        onReceived: text => {
            root.repo = root.parse(text);
            root.repoPending = false;
        }
    }

    Poller {
        id: aurPoller

        command: ["sh", "-c", Commands.aurUpdates.arg(Appearance.updates.timeout)]
        interval: Appearance.updates.pollInterval

        onReceived: text => {
            root.aur = root.parse(text);
            root.aurPending = false;
        }
    }
}
