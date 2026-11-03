import QtQuick
import qs.services

Image {
    id: root

    required property var screen
    property string path

    readonly property string screenName: root.screen?.name ?? ""
    readonly property bool spans: WallpaperLayout.spans(root.path, root.screenName)
    readonly property rect desktop: WallpaperLayout.desktop()
    readonly property size area: root.spans ? Qt.size(root.desktop.width, root.desktop.height) : Qt.size(root.screen?.width ?? 0, root.screen?.height ?? 0)

    x: root.spans ? root.desktop.x - root.screen.x : 0
    y: root.spans ? root.desktop.y - root.screen.y : 0
    width: root.area.width
    height: root.area.height

    source: root.path && root.area.width > 0 ? `file://${root.path}` : ""
    fillMode: WallpaperLayout.fillModeFor(root.path, root.screenName)
    asynchronous: true
    cache: true
    sourceSize: WallpaperLayout.isUnscaled(root.path, root.screenName) ? undefined : root.area
}
