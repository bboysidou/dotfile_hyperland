import QtQuick

QtObject {
    readonly property string labelNetworks: "Networks"
    readonly property string labelSpeedTest: "Speed test"
    readonly property string labelDownload: "Download"
    readonly property string labelUpload: "Upload"
    readonly property var units: ["Kbps", "Mbps", "Gbps"]
    readonly property string gigaSuffix: "G"
    readonly property string labelSource: "fast.com"
    readonly property string labelMeasuring: "Measuring %1..."
    readonly property string labelFailed: "Speed test failed"
    readonly property string labelIdle: "Ready"
    readonly property string labelDone: "Test done"
    readonly property string labelStart: "Start test"
    readonly property string labelStop: "Stop"
    readonly property string labelAgain: "Run again"
    readonly property string timeFormat: "HH:mm"

    readonly property int resultSpacing: 12
    readonly property int resultGlyphSize: 20
    readonly property int resultValueSize: 22
    readonly property int resultUnitSize: 12
    readonly property int resultLabelSize: 11
    readonly property int resultTextSpacing: 2

    readonly property int phaseSeconds: 8
    readonly property int warmupSamples: 1
    readonly property int valueDecimals: 2

    readonly property var scales: [[0, 5, 10, 50, 100, 250, 500, 750, 1000], [0, 50, 100, 500, 1000, 2500, 5000, 7500, 10000]]
    readonly property real startAngle: 135
    readonly property real span: 270

    readonly property int dialSize: 280
    readonly property int dialSpacing: 18
    readonly property int strokeWidth: 26
    readonly property int tickInset: 26
    readonly property int tickSize: 13
    readonly property int valueSize: 40
    readonly property int unitSize: 13
    readonly property int unitGlyphSize: 15
    readonly property int unitSpacing: 6
    readonly property int footerDrop: 16
    readonly property real downloadHueShift: 0.1
    readonly property real uploadHueShift: -0.15
    readonly property real tailLightness: 1.15
    readonly property real gradientAngle: 270
    readonly property real gradientHead: 0.125
    readonly property real gradientTail: 0.875
    readonly property int valueWeight: Font.Light

    readonly property real needleInner: 0.2
    readonly property real needleOuter: 0.6
    readonly property int needleTipWidth: 2
    readonly property int needleBaseWidth: 10
    readonly property real needleOpacity: 0.95

    readonly property int valueDuration: 900
}
