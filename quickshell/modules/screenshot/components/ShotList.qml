pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.screenshot

FadeListView {
    id: root

    property string search: ""

    readonly property var results: ShotState.results
    readonly property var current: root.results[root.currentIndex] ?? null
    readonly property int rowHeight: Appearance.shot.iconSize + Appearance.shot.rowPaddingV * 2

    signal activated(var entry)

    function step(delta: int): void {
        if (root.count === 0)
            return;

        root.currentIndex = Num.wrap(root.currentIndex, delta, root.count);
    }

    model: root.results
    clip: true
    spacing: Appearance.shot.rowSpacing
    boundsBehavior: Flickable.StopAtBounds
    keyNavigationEnabled: false
    highlightMoveDuration: Appearance.anim.durations.fastEffects

    implicitHeight: root.count > 0 ? root.count * root.rowHeight + (root.count - 1) * root.spacing : 0

    onResultsChanged: root.currentIndex = 0
    onCurrentIndexChanged: root.positionViewAtIndex(root.currentIndex, ListView.Contain)

    delegate: ShotEntry {
        required property var modelData
        required property int index

        width: root.width

        entry: modelData
        selected: index === root.currentIndex

        onClicked: root.activated(modelData)
    }
}
