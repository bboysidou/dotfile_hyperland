import QtQuick

QtObject {
    readonly property string dir: "Pictures/wallpaper"
    readonly property string stateFile: "wallpaper"
    readonly property string fitStateFile: "wallpaper-fit.json"
    readonly property int fitSaveDebounce: 400
    readonly property var extensions: ["jpg", "jpeg", "png", "gif"]
}
