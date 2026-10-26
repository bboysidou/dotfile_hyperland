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
    readonly property int shakeAmplitude: 12
    readonly property int shakeStep: 55
    readonly property real shakeDecay: 0.5
    readonly property int flashHold: 500
    readonly property real dotCollapseScale: 0.85
    readonly property string pamConfig: "lock"
    readonly property string pamDir: "core/config/pam"
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
