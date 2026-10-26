import QtQuick
import qs.services

AnimatedImage {
    id: root

    required property var screen
    property string path

    readonly property string screenName: root.screen?.name ?? ""
    readonly property bool spans: WallpaperLayout.spans(root.path, root.screenName)
    readonly property rect desktop: WallpaperLayout.desktop()
    readonly property real screenWidth: root.parent?.width ?? 0
    readonly property real screenHeight: root.parent?.height ?? 0

    x: root.spans ? root.desktop.x - root.screen.x : 0
    y: root.spans ? root.desktop.y - root.screen.y : 0
    width: root.spans ? root.desktop.width : root.screenWidth
    height: root.spans ? root.desktop.height : root.screenHeight

    source: root.path ? `file://${root.path}` : ""
    fillMode: WallpaperLayout.fillModeFor(root.path, root.screenName)
    asynchronous: true
    sourceSize: WallpaperLayout.isUnscaled(root.path, root.screenName) ? undefined : Qt.size(root.width, root.height)
}
