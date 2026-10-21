import QtQuick

QtObject {
    readonly property string action: "clip"
    readonly property string placeholder: "Clipboard..."
    readonly property string emptyTitle: "Clipboard is empty"
    readonly property string emptySubtitle: "Copied text and images show up here"
    readonly property string hint: "\u21b5 copy \u00b7 shift del remove \u00b7 ctrl shift del clear all"
    readonly property int hintSize: 11
    readonly property real hintOpacity: 0.9
    readonly property string cacheDir: "quickshell/clipboard"
    readonly property int maxEntries: 200
    readonly property int visibleRows: 6
    readonly property int thumbWidth: 86
    readonly property int thumbHeight: 48
    readonly property int thumbRounding: 8
    readonly property int textLines: 2
    readonly property int emptyMargin: 24
}
