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
    readonly property string labelDefaultSink: "Default"

    readonly property int routeHeight: 26
    readonly property int routeOptionHeight: 26
    readonly property int routeSpacing: 2
    readonly property int routeRounding: 8
    readonly property int routePaddingH: 8
    readonly property int routeIconSize: 14
    readonly property int routeTextSize: 11

    readonly property int meterThickness: 4
    readonly property int meterTopMargin: 2
    readonly property real meterFloorDb: -60
    readonly property real meterDbScale: 20
    readonly property int meterInterval: 16
    readonly property real meterRelease: 0.02
    readonly property int meterHoldDuration: 900
    readonly property real meterHoldRelease: 0.008
    readonly property int meterHoldWidth: 2
    readonly property real meterMutedOpacity: 0.4

    readonly property int spectrumHeight: 34
    readonly property int spectrumTopMargin: 4
    readonly property int spectrumBars: 32
    readonly property string spectrumMethod: "pipewire"
    readonly property real spectrumOpacity: 0.85
    readonly property real spectrumBarRatio: 0.6
    readonly property int spectrumMinBar: 2
    readonly property int spectrumDuration: 80
    readonly property real spectrumGain: 1.25
    readonly property real spectrumCurve: 0.7

    readonly property string labelMicTest: "Hear yourself"
    readonly property string labelMicTestDetail: "Plays this mic through the output"
}
