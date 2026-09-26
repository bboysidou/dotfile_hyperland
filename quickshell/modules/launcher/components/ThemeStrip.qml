pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.helpers
import qs.services

PathView {
    id: root

    property string search: ""
    property int visibleItems: 1

    readonly property var entries: Theme.query(root.search)
    readonly property string selected: root.entries[root.currentIndex] ?? ""
    readonly property int itemWidth: Appearance.launcher.wallpaperItemWidth + Appearance.launcher.wallpaperItemPadding * 2

    signal activated(string name)

    function sync(): string {
        const index = root.search ? 0 : Math.max(0, root.entries.indexOf(Theme.committed));
        root.currentIndex = index;
        return root.entries[index] ?? "";
    }

    function step(delta: int): void {
        if (root.entries.length === 0)
            return;

        root.currentIndex = Num.wrap(root.currentIndex, delta, root.entries.length);
        Theme.preview(root.entries[root.currentIndex] ?? "");
    }

    model: root.entries

    implicitWidth: Math.min(root.visibleItems, root.count) * root.itemWidth
    implicitHeight: Appearance.launcher.wallpaperItemWidth * Appearance.launcher.wallpaperAspect + Appearance.launcher.wallpaperLabelSpacing + Appearance.launcher.wallpaperLabelHeight + Appearance.launcher.wallpaperItemPadding * 2

    pathItemCount: root.visibleItems
    highlightMoveDuration: Appearance.anim.durations.fastEffects
    snapMode: PathView.SnapToItem
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange

    Component.onCompleted: root.sync()
    Component.onDestruction: Theme.stopPreview()

    onEntriesChanged: {
        const name = root.sync();
        if (root.search)
            Theme.preview(name);
    }
    onMovementEnded: Theme.preview(root.entries[root.currentIndex] ?? "")

    delegate: ThemeCard {
        onClicked: root.activated(modelData)
    }

    path: Path {
        startY: root.height / 2

        PathAttribute {
            name: "z"
            value: 0
        }
        PathLine {
            x: root.width / 2
            relativeY: 0
        }
        PathAttribute {
            name: "z"
            value: 1
        }
        PathLine {
            x: root.width
            relativeY: 0
        }
    }
}
