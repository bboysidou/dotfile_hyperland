import QtQuick

QtObject {
    readonly property string action: "clip"
    readonly property string placeholder: "Clipboard..."
    readonly property string emptyTitle: "Clipboard is empty"
    readonly property string emptySubtitle: "Copied text and images show up here"
    readonly property string cacheDir: "quickshell/clipboard"
    readonly property int maxEntries: 200
    readonly property int visibleRows: 6
    readonly property int thumbWidth: 86
    readonly property int thumbHeight: 48
    readonly property int thumbRounding: 8
    readonly property int textLines: 2
    readonly property int emptyMargin: 24
}
