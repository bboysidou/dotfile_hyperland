import QtQuick
import QtQuick.Effects
import qs.core.components
import qs.core.config
import qs.services

Item {
    id: root

    required property var screen

    Rectangle {
        id: shot

        anchors.fill: parent

        color: Colours.surface
        visible: false
        clip: true

        WallpaperImage {
            screen: root.screen
            path: WallpaperLayout.currentFor(root.screen?.name ?? "")
            playing: false
        }
    }

    MultiEffect {
        anchors.fill: parent

        source: shot
        blurEnabled: true
        blur: Appearance.lock.blur
        blurMax: Appearance.lock.blurMax
        autoPaddingEnabled: false
    }

    Rectangle {
        anchors.fill: parent

        color: Colours.surface
        opacity: Appearance.lock.backgroundDim
    }
}
