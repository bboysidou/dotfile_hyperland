import QtQuick

QtObject {
    readonly property int panelWidth: 700
    readonly property int stageHeight: 620
    readonly property int maxNodes: 8

    readonly property int coreSize: 150
    readonly property int coreBorderWidth: 2
    readonly property int coreGlyphSize: 40
    readonly property int coreLabelSize: 13
    readonly property int coreDetailSize: 11
    readonly property int coreTextSpacing: 4
    readonly property real coreHighlight: 1.15
    readonly property real coreBorderHighlight: 1.1

    readonly property int glowInset: 30
    readonly property real glowOpacity: 0.15
    readonly property int glowPeriod: 2000
    readonly property real glowScale: 1.1

    readonly property int pulseInset: 12
    readonly property int pulseWidth: 2
    readonly property int pulseInterval: 45
    readonly property real pulseBaseOpacity: 0.3
    readonly property real pulseSwingOpacity: 0.15
    readonly property real pulseBaseScale: 1.02
    readonly property real pulseSwingScale: 0.02
    readonly property real pulseOpacityRate: 2.5
    readonly property real pulseScaleRate: 3

    readonly property int rippleCount: 3
    readonly property real rippleRatio: 0.4
    readonly property int rippleWidth: 2
    readonly property int ripplePeriod: 2000
    readonly property int rippleStagger: 400
    readonly property real rippleScaleTo: 2.5
    readonly property real rippleOpacityFrom: 0.8
    readonly property int glyphPulsePeriod: 1000
    readonly property real glyphPulseOpacity: 0.5

    readonly property int nodeWidth: 140
    readonly property int nodeHeight: 48
    readonly property int nodeSpacing: 6
    readonly property int nodePaddingH: 10
    readonly property int nodeGlyphSize: 18
    readonly property int nodeLabelSize: 12
    readonly property int nodeBadgeSize: 11
    readonly property int nodeEntryStep: 30
    readonly property int nodeEntryDelay: 40
    readonly property int nodeDriftDistance: 32
    readonly property int fillDuration: 600
    readonly property int failFlashDuration: 500
    readonly property real failFlashOpacity: 0.6
    readonly property int spinPeriod: 800

    readonly property int radiusX: 236
    readonly property int radiusYInner: 176
    readonly property int radiusYOuter: 232
    readonly property int rings: 2
    readonly property int swayPeriod: 9000
    readonly property real swayAmount: 0.09
    readonly property real pinnedAngle: Math.PI / 2

    readonly property int radarCount: 3
    readonly property int radarBase: 220
    readonly property int radarStep: 130
    readonly property real radarOpacity: 0.08
    readonly property real radarFalloff: 0.02
    readonly property real radarIdleOpacity: 0.03

    readonly property real orbPrimaryRatio: 0.8
    readonly property real orbSecondaryRatio: 0.9
    readonly property real orbPrimaryDriftX: 120
    readonly property real orbPrimaryDriftY: 80
    readonly property real orbSecondaryDriftX: -120
    readonly property real orbSecondaryDriftY: -80
    readonly property real orbPrimaryRate: 2
    readonly property real orbSecondaryRate: 1.5
    readonly property real orbPrimaryOpacity: 0.03
    readonly property real orbSecondaryOpacity: 0.02
    readonly property real orbIdleOpacity: 0.01
    readonly property real orbPrimaryDangerOpacity: 0.05
    readonly property real orbSecondaryDangerOpacity: 0.04
    readonly property real orbSecondaryShade: 1.25

    readonly property int strandInterval: 25
    readonly property int strandSteps: 22
    readonly property int strandStartGap: 5
    readonly property int strandEndGap: 26
    readonly property real strandFalloff: 420
    readonly property real strandCoreWidth: 1
    readonly property real strandCoreGain: 1.2
    readonly property real strandGlowWidth: 4.5
    readonly property real strandGlowGain: 3
    readonly property real strandBaseAlpha: 0.35
    readonly property real strandDistanceAlpha: 0.65
    readonly property real strandGlowAlpha: 0.22
    readonly property real strandMidAlpha: 0.55
    readonly property real strandCoreAlpha: 0.95
    readonly property real strandIdleAlpha: 0.25
    readonly property real strandMidHighlight: 1.35
    readonly property real strandWaveFast: 3.4
    readonly property real strandWaveMid: 2.5
    readonly property real strandWaveSlow: -1.5
    readonly property real strandAmpFast: 9
    readonly property real strandAmpMid: 5.5
    readonly property real strandAmpSlow: 7
    readonly property real strandFreqFast: 9
    readonly property real strandFreqMid: 6
    readonly property real strandFreqSlow: 8
    readonly property string strandCoreColour: "#ffffff"

    readonly property int powerRestSize: 140
    readonly property int powerDockSize: 42
    readonly property int powerDockMargin: 24
    readonly property int powerRestGlyphSize: 54
    readonly property int powerDockGlyphSize: 20
    readonly property real powerHoverScale: 1.05
    readonly property real powerPressScale: 0.95

    readonly property int holdDuration: 700
    readonly property int wavePeriod: 800
    readonly property real waveAmplitude: 10


    readonly property string labelFound: "%1 found"
    readonly property string labelOnline: "Online"
    readonly property string labelExtra: "+%1"
}
