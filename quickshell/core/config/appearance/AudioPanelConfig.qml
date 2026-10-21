import QtQuick

QtObject {
    readonly property int orbSize: 96
    readonly property int orbRounding: 14
    readonly property int orbReadoutSize: 26
    readonly property int orbRingInset: 6
    readonly property int orbGlowInset: 10
    readonly property int orbRingWidth: 2
    readonly property int orbFillInset: 3
    readonly property real orbRingOpacity: 0.55
    readonly property real orbGlowOpacity: 0.08
    readonly property real orbWaveAmplitude: 6
    readonly property int orbWavePeriod: 1200
    readonly property real orbFullRatio: 0.99
    readonly property real orbHighlight: 1.15
    readonly property int orbBreathePeriod: 2000
    readonly property real orbBreatheScale: 1.02

    readonly property int heroHeight: 110
    readonly property int heroSpacing: 14
    readonly property int heroTextSpacing: 2
    readonly property int heroNameSize: 16
    readonly property int heroDetailSize: 11
    readonly property int heroControlSpacing: 10
    readonly property int heroMuteSize: 26

    readonly property int groupSpacing: 6
    readonly property int groupTopMargin: 14
    readonly property int groupLabelSize: 11


    readonly property int introHeaderDelay: 100
    readonly property int introContentDelay: 200
    readonly property int introHeaderDuration: 700
    readonly property int introContentDuration: 800
    readonly property real introOvershoot: 1.2
    readonly property int introHeaderLift: 20
    readonly property int introContentLift: 15

    readonly property int switchTopMargin: 14
    readonly property int listTopMargin: 12
    readonly property string labelOutputs: "Outputs"
    readonly property string labelInputs: "Inputs"
    readonly property string labelStreams: "Streams"
    readonly property string labelActiveDefault: "Active default"
    readonly property string labelMuted: "MUTE"
    readonly property string labelNoDevice: "No device"
    readonly property string emptyStreams: "Nothing playing"
    readonly property string labelStreamVolume: "Stream volume"
}
