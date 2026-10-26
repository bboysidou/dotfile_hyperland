import QtQuick
import qs.services

AnimatedImage {
    id: root

    required property var screen
    property string path

    readonly property bool spans: Wallpaper.spans(root.path)
    readonly property rect desktop: Wallpaper.desktop()
    readonly property real screenWidth: root.parent?.width ?? 0
    readonly property real screenHeight: root.parent?.height ?? 0

    x: root.spans ? root.desktop.x - root.screen.x : 0
    y: root.spans ? root.desktop.y - root.screen.y : 0
    width: root.spans ? root.desktop.width : root.screenWidth
    height: root.spans ? root.desktop.height : root.screenHeight

    source: root.path ? `file://${root.path}` : ""
    fillMode: Wallpaper.fillModeFor(root.path)
    asynchronous: true
    sourceSize: Wallpaper.isUnscaled(root.path) ? undefined : Qt.size(root.width, root.height)
}
