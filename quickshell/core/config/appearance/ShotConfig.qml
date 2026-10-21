import QtQuick

QtObject {
    readonly property int width: 500
    readonly property int padding: 20
    readonly property int spacing: 10
    readonly property int rowSpacing: 5
    readonly property int rowPaddingV: 6
    readonly property int rowPaddingH: 10
    readonly property int rowContentSpacing: 10
    readonly property int rowRounding: 12
    readonly property int iconSize: 32
    readonly property real scaleFrom: 0.95
    readonly property real subtitleOpacity: 0.7
    readonly property string placeholder: "Screenshot..."
    readonly property int captureDelay: 450
    readonly property int fullscreenDelay: 1
    readonly property string dir: "Pictures/screenshots"
    readonly property string fileFormat: "'screenshot_'yyyy-MM-dd_HH-mm-ss'.png'"
    readonly property string notifyTitle: "Screenshot created"
    readonly property string showInFolderLabel: "Show in folder"
    readonly property string regionLabel: "Selected area"
    readonly property string fullscreenLabel: "Fullscreen"
    readonly property string ocrLabel: "OCR"
    readonly property string regionSubtitle: "Drag to pick a region"
    readonly property string fullscreenSubtitle: "Whole screen after 1s"
    readonly property string ocrSubtitle: "Region to text, copied to clipboard"
}
