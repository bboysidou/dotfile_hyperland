import QtQuick

QtObject {
    readonly property var palette: ["#ef4444", "#f97316", "#facc15", "#22c55e", "#3b82f6", "#a855f7", "#000000", "#ffffff"]
    readonly property var widths: [3, 5, 8, 12]
    readonly property int defaultColor: 0
    readonly property int defaultWidth: 1
    readonly property int highlightColor: 2
    readonly property int highlightWidth: 22
    readonly property real highlightOpacity: 0.4
    readonly property real headLength: 3.2
    readonly property real headWidth: 3.0
    readonly property int headMin: 10
    readonly property real headMaxRatio: 0.45
    readonly property real pointyTail: 0.25
    readonly property real pointyBody: 1.6
    readonly property real curveOverlap: 0.25
    readonly property int curveSamples: 24
    readonly property string redactColor: "#000000"
    readonly property int pixelBlock: 14
    readonly property int minCrop: 8
    readonly property var backdrops: [["#6366f1", "#ec4899"], ["#0ea5e9", "#22c55e"], ["#f97316", "#facc15"], ["#334155", "#0f172a"], ["#f8fafc", "#cbd5e1"]]
    readonly property real backdropRatio: 0.06
    readonly property int backdropRounding: 14
    readonly property int shadowBlur: 36
    readonly property int shadowOffset: 10
    readonly property real shadowOpacity: 0.45
    readonly property int handleSize: 10
    readonly property int handleBorder: 2
    readonly property int markerBase: 26
    readonly property int markerPerWidth: 3
    readonly property real markerFont: 0.55
    readonly property int textBase: 22
    readonly property int textPerWidth: 2
    readonly property real textPaddingH: 0.45
    readonly property real textPaddingV: 0.2
    readonly property real textRounding: 0.3
    readonly property real pillOpacity: 0.72
    readonly property real lightThreshold: 0.6
    readonly property int margin: 48
    readonly property int gap: 14
    readonly property int hitTolerance: 8
    readonly property int minDrag: 3
    readonly property int nudge: 1
    readonly property int nudgeLarge: 10
    readonly property real dimOpacity: 0.78
    readonly property int toolbarHeight: 92
    readonly property int buttonMinWidth: 52
    readonly property int buttonPaddingH: 8
    readonly property int buttonPaddingV: 6
    readonly property int buttonGap: 4
    readonly property int buttonRounding: 8
    readonly property int buttonBorder: 1
    readonly property real disabledOpacity: 0.5
    readonly property int toolbarPadding: 8
    readonly property int toolbarSpacing: 4
    readonly property int toolbarRounding: 12
    readonly property int iconSize: 20
    readonly property int swatchSize: 18
    readonly property int swatchRing: 2
    readonly property int dividerWidth: 1
    readonly property int dividerInset: 10
    readonly property int selectionWidth: 1
    readonly property int selectionPad: 6
    readonly property string editAction: "Edit"
    readonly property string editedLabel: "Edited"
    readonly property string copiedTitle: "Copied to clipboard"
    readonly property string failLoad: "Could not open the image in the editor"
    readonly property string ocrLanguage: "eng"
    readonly property string ocrTitle: "Text copied"
    readonly property string ocrEmpty: "No text found"
    readonly property int ocrPreviewLength: 240
    readonly property string failOcr: "Could not read text from the image"
    readonly property string failExport: "Could not export the edited image"
}
