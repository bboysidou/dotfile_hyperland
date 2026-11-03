import QtQuick

QtObject {
    readonly property real dimOpacity: 0.45
    readonly property int borderWidth: 2
    readonly property int windowBorderWidth: 3
    readonly property int windowRounding: 10
    readonly property int dragThreshold: 6
    readonly property int readoutOffset: 18
    readonly property int readoutPaddingH: 10
    readonly property int readoutPaddingV: 4
    readonly property int readoutRounding: 8
    readonly property int readoutSize: 12
    readonly property int captureTimeout: 2000
    readonly property int maxSuffix: 99
    readonly property string sizeSeparator: " × "
    readonly property string coordSeparator: ", "
    readonly property string filePattern: "'screenshot_'yyyy-MM-dd_HH-mm-ss"
    readonly property string tempFile: "qs-screenshot-%1-%2-%3.png"
    readonly property string regionLabel: "Region"
    readonly property string windowLabel: "Window"
    readonly property string monitorLabel: "Monitor"
    readonly property string annotateTag: "EDIT"
    readonly property string failTitle: "Screenshot failed"
    readonly property string failTimeout: "No frame from the compositor within 2 s"
    readonly property string failGrab: "Could not render the captured frame"
    readonly property string failSave: "Could not write the temporary image"
    readonly property string failOutput: "Could not crop, save or copy the image"
}
