import QtQuick

QtObject {
    readonly property string stateFile: "theme.json"
    readonly property var labels: ({
            "default": "Default",
            "monochrome": "Monochrome",
            "hacker": "Hacker"
        })
    readonly property int frameBorder: 1
    readonly property int swatchSize: 10
    readonly property int swatchSpacing: 6
    readonly property int mockPadding: 14
    readonly property int mockBarHeight: 14
    readonly property int mockPillWidth: 34
    readonly property int mockLineHeight: 6
    readonly property int mockLineSpacing: 8
    readonly property real mockLineLong: 0.7
    readonly property real mockLineShort: 0.45
}
