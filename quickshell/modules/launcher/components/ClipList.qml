pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

FadeListView {
    id: root

    property string search: ""

    readonly property var results: Clipboard.query(root.search)
    readonly property var current: root.results[root.currentIndex] ?? null
    readonly property int rowHeight: Appearance.clipboard.thumbHeight + Appearance.launcher.rowPaddingV * 2
    readonly property int rows: Math.min(root.count, Appearance.clipboard.visibleRows)

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

    implicitHeight: root.rows > 0 ? root.rows * root.rowHeight + (root.rows - 1) * root.spacing : empty.implicitHeight + Appearance.clipboard.emptyMargin * 2

    onSearchChanged: root.currentIndex = 0
    onResultsChanged: root.currentIndex = Math.max(0, Math.min(root.currentIndex, root.results.length - 1))
    onCurrentIndexChanged: root.positionViewAtIndex(root.currentIndex, ListView.Contain)

    EmptyState {
        id: empty

        anchors.centerIn: parent

        visible: root.count === 0
        glyph: Icons.clipboard
        title: Appearance.clipboard.emptyTitle
        subtitle: Appearance.clipboard.emptySubtitle
    }

    delegate: ClipEntry {
        required property var modelData
        required property int index

        width: root.width

        entry: modelData
        selected: index === root.currentIndex

        onClicked: root.activated(modelData)
    }
}
