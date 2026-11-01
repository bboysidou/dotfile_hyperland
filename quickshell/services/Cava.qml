pragma Singleton

import Quickshell
import qs.core.components
import qs.core.config

Singleton {
    id: root

    property bool active: false

    readonly property int bars: Appearance.dash.visualiserBars
    readonly property var values: feed.values

    CavaFeed {
        id: feed

        running: root.active
        bars: root.bars
    }
}
