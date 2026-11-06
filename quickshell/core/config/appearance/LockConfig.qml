import QtQuick
import qs.core.enums

QtObject {
    readonly property string clockFont: "Alfa Slab One"
    readonly property string labelFont: "SF Pro Display"
    readonly property int labelWeight: Font.Bold
    readonly property int clockWeight: Font.Normal
    readonly property int clockFontSize: 240
    readonly property int dateFontSize: 40
    readonly property int greetingFontSize: 21
    readonly property int identityFontSize: 15
    readonly property int clockSpacing: -60
    readonly property int centreSpacing: 12
    readonly property int fieldWidth: 250
    readonly property int fieldHeight: 60
    readonly property int fieldRounding: 1000
    readonly property int fieldBorderWidth: 2
    readonly property int fieldPaddingH: 30
    readonly property int fieldTopMargin: 40
    readonly property real blur: 1.0
    readonly property int blurMax: 64
    readonly property real backgroundDim: 0.35
    readonly property int logoSize: 100
    readonly property real logoOpacity: 0.25
    readonly property int edgeMargin: 20
    readonly property int identitySpacing: 12
    readonly property int statusSpacing: 10
    readonly property int statusPaddingV: 6
    readonly property int statusPaddingH: 12
    readonly property int statusRounding: 12
    readonly property int statusIconSize: 18
    readonly property int statusFontSize: 16
    readonly property int messageFontSize: 17
    readonly property int messageTopMargin: 12
    readonly property int mediaMaxWidth: 320
    readonly property int faillockDeny: 10
    readonly property int faillockCooldown: 120
    readonly property int faillockCooldownMax: 120
    readonly property int faillockTick: 1000
    readonly property int faillockWindow: 600000
    readonly property int recoverTimeout: 2000
    readonly property int pamTimeout: 20000
    readonly property int focusPollInterval: 500
    readonly property int sleepMonitorRetry: 2000
    readonly property string fadeInType: AnimType.standardLarge
    readonly property string fadeOutType: AnimType.standard
    readonly property int fadeInDuration: 300
    readonly property int fadeOutDuration: 300
    readonly property int previewHold: 2500
    readonly property int shakeAmplitude: 12
    readonly property int shakeStep: 55
    readonly property real shakeDecay: 0.5
    readonly property int flashHold: 500
    readonly property real dotCollapseScale: 0.85
    readonly property int introStrandDelay: 120
    readonly property int introStrandDuration: 700
    readonly property int introStrandRetract: 360
    readonly property int introOrbDuration: 520
    readonly property real introOrbFrom: 0.2
    readonly property real introOrbFade: 2
    readonly property int introOpenHold: 280
    readonly property int introDropDuration: 170
    readonly property real introPunchScale: 1.14
    readonly property int introPunchOut: 70
    readonly property int introPunchBack: 460
    readonly property int introHold: 650
    readonly property int introRepaint: 16
    readonly property real introStrandGlowWidth: 10
    readonly property real introStrandMidWidth: 4
    readonly property real introStrandCoreWidth: 2
    readonly property real introStrandGlowAlpha: 0.3
    readonly property real introStrandMidAlpha: 0.65
    readonly property real introStrandCoreAlpha: 0.95
    readonly property real introHeadSize: 4
    readonly property real introHeadBlur: 22
    readonly property int introBurstDuration: 780
    readonly property int introFlashDuration: 300
    readonly property real introFlashOpacity: 0.85
    readonly property int introRingCount: 3
    readonly property real introRingStagger: 0.12
    readonly property real introRingGrow: 380
    readonly property real introRingWidth: 6
    readonly property real introRingOpacity: 1
    readonly property int introSparkCount: 18
    readonly property real introSparkReach: 200
    readonly property real introSparkLength: 30
    readonly property real introSparkThickness: 4
    readonly property real introSparkJitter: 0.2
    readonly property real padlockBodyWidth: 58
    readonly property real padlockBodyHeight: 44
    readonly property real padlockBodyRadius: 11
    readonly property real padlockShackleWidth: 38
    readonly property real padlockShackleHeight: 48
    readonly property real padlockShackleStroke: 7
    readonly property real padlockLift: 16
    readonly property real padlockLegCut: 14
    readonly property real padlockKeyholeSize: 11
    readonly property real padlockKeyStemWidth: 4
    readonly property real padlockKeyStemHeight: 10
    readonly property string pamConfig: "lock"
    readonly property string pamDir: "core/config/pam"
    readonly property string fingerprintPamConfig: "fingerprint"
    readonly property int fingerprintMaxTries: 5
    readonly property int fingerprintErrorRetries: 5
    readonly property int fingerprintRetryDelay: 1500
    readonly property string fingerprintPrompt: "Or use your fingerprint"
    readonly property string fingerprintTouch: "Touch the sensor or start typing"
    readonly property int typingHold: 6000
    readonly property int orbSize: 96
    readonly property int orbRippleCount: 3
    readonly property int orbRippleSize: 65
    readonly property real orbRippleScale: 1.46
    readonly property real orbRippleWidth: 1
    readonly property real orbRippleOpacity: 0.7
    readonly property int orbRipplePeriod: 1800
    readonly property int orbGlyphSize: 68
    readonly property real orbGlyphStroke: 1.8
    readonly property real orbGlyphCentre: 0.63
    readonly property int readEstimate: 1000
    readonly property int readEstimateMin: 200
    readonly property int readEstimateMax: 2500
    readonly property real readFillCap: 0.9
    readonly property int readFillFinish: 140
    readonly property int readDrain: 260
    readonly property int readGrace: 1500
    readonly property int modeFade: 180
    readonly property string fingerprintMismatch: "Fingerprint not recognised"
    readonly property string fingerprintExhausted: "Too many fingerprint attempts, use your password"
    readonly property string stateFile: "lock.json"
    readonly property string greetingTemplate: "Hello, %1! %2"
    readonly property string placeholderTemplate: "Hi, %1"
    readonly property string failureSingular: "%1 failed attempt"
    readonly property string cooldownTemplate: "Locked out, retry in %1s"
    readonly property string pamUnavailable: "Authentication unavailable"
    readonly property string pamTimedOut: "Authentication timed out"
    readonly property string focusWarning: "Keyboard not captured, click to restore"
    readonly property string failurePlural: "%1 failed attempts"
    readonly property string missedTemplate: "%1 missed"
    readonly property string greetingMorning: "Good Morning"
    readonly property string greetingAfternoon: "Good Afternoon"
    readonly property string greetingEvening: "Good Evening"
    readonly property string greetingNight: "Good Night"
    readonly property string greetingLate: "GO TO SLEEP!"
    readonly property int hourMorning: 5
    readonly property int hourAfternoon: 12
    readonly property int hourEvening: 17
    readonly property int hourNight: 21
    readonly property string dateFormat: "dddd, dd MMMM"
    readonly property string hourFormat: "HH"
    readonly property string minuteFormat: "mm"
    readonly property string packagesTemplate: "Packages: %1 pacman"
    readonly property string emptyNoNetwork: "Offline"
    readonly property string emptyNoBluetooth: "Bluetooth off"
}
