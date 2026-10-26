pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.enums
import qs.services

Row {
    id: root

    property string path

    spacing: Appearance.launcher.fitSpacing

    Repeater {
        model: WallpaperFit.values

        FitChip {
            required property string modelData

            label: WallpaperFit.labels[modelData]
            letter: WallpaperFit.letters[modelData]
            active: Wallpaper.fitFor(root.path) === modelData

            onTriggered: Wallpaper.setFit(root.path, modelData)
        }
    }
}
