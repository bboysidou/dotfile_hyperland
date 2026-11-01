import QtQuick

QtObject {
    readonly property int max: 100
    readonly property int step: 1
    readonly property int mediumFloor: 31
    readonly property int highFloor: 66

    readonly property string metadataCommand: "pw-metadata"
    readonly property string metadataDelete: "-d"
    readonly property string targetKey: "target.object"
    readonly property string legacyTargetKey: "target.node"
    readonly property string targetType: "Spa:Id"
    readonly property string serialKey: "object.serial"
    readonly property string smartFilterKey: "filter.smart"
    readonly property string linkGroupKey: "node.link-group"
    readonly property string trueValue: "true"

    readonly property string loopbackCommand: "pw-loopback"
    readonly property string loopbackNameFlag: "-n"
    readonly property string loopbackCaptureFlag: "-C"
    readonly property string micTestName: "quickshell-mic-test"
    readonly property string micTestOutput: "output.quickshell-mic-test"
}
