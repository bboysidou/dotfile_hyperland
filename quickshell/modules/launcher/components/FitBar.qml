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
        model: WallpaperLayout.fitsAvailable()

        FitChip {
            required property string modelData

            label: WallpaperFit.labels[modelData]
            letter: WallpaperFit.letters[modelData]
            active: WallpaperLayout.fitFor(root.path, WallpaperLayout.target) === modelData

            onTriggered: WallpaperLayout.setFit(root.path, modelData)
        }
    }
}
