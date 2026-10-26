pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.services

Row {
    id: root

    spacing: Appearance.launcher.fitSpacing

    FitChip {
        label: Appearance.launcher.linkLabel
        letter: Appearance.launcher.linkLetter
        active: WallpaperLayout.linked

        onTriggered: WallpaperLayout.setLinked(!WallpaperLayout.linked)
    }

    Repeater {
        model: WallpaperLayout.linked ? [] : WallpaperLayout.ordered

        FitChip {
            required property var modelData
            required property int index

            label: modelData.name
            letter: String(index + 1)
            active: WallpaperLayout.target === modelData.name

            onTriggered: WallpaperLayout.pick(index)
        }
    }
}
