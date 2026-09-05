pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

FadeListView {
    id: root

    property string search: ""

    readonly property var results: Apps.query(root.search)
    readonly property var current: root.results[root.currentIndex] ?? null
    readonly property int rowHeight: Appearance.launcher.iconSize + Appearance.launcher.rowPaddingV * 2
    readonly property int rows: Math.min(root.count, Appearance.launcher.visibleRows)

    signal activated(var entry)

    function step(delta: int): void {
        if (root.count === 0)
            return;

        root.currentIndex = Num.wrap(root.currentIndex, delta, root.count);
    }

    model: root.results
    clip: true
    spacing: Appearance.launcher.rowSpacing
    boundsBehavior: Flickable.StopAtBounds
    keyNavigationEnabled: false
    highlightMoveDuration: Appearance.anim.durations.fastEffects

    implicitHeight: root.rows > 0 ? root.rows * root.rowHeight + (root.rows - 1) * root.spacing : 0

    onResultsChanged: root.currentIndex = 0
    onCurrentIndexChanged: root.positionViewAtIndex(root.currentIndex, ListView.Contain)

    delegate: AppEntry {
        required property var modelData
        required property int index

        width: root.width

        entry: modelData
        selected: index === root.currentIndex

        onClicked: root.activated(modelData)
    }
}
