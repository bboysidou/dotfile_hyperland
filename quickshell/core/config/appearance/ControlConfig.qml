import QtQuick

QtObject {
    readonly property int width: 383
    readonly property int padding: 14
    readonly property real scaleFrom: 0.96
    readonly property int paneSpacing: 8
    readonly property int sectionHeaderHeight: 34
    readonly property int sectionHeaderSpacing: 10
    readonly property int sectionIconSize: 18
    readonly property int sectionContentSpacing: 4
    readonly property int rowHeight: 34
    readonly property int rowPaddingV: 6
    readonly property int rowPaddingH: 10
    readonly property int rowSpacing: 10
    readonly property int rowRounding: 10
    readonly property int iconSize: 18
    readonly property int toggleWidth: 44
    readonly property int toggleHeight: 24
    readonly property int togglePadding: 3
    readonly property int toggleThumbOff: 12
    readonly property int togglePressedGrow: 2
    readonly property int toggleBorderWidth: 2
    readonly property int toggleIconSize: 12
    readonly property int focusBorderWidth: 1
    readonly property real disabledOpacity: 0.4
    readonly property int passwordPaddingV: 8
    readonly property int passwordPaddingH: 12
    readonly property int passwordSpacing: 8
    readonly property int forgetConfirmTimeout: 3000
    readonly property int detailPollInterval: 15000
    readonly property int wanPollInterval: 600000
    readonly property int rssiPollInterval: 5000
    readonly property int wifiSignalLow: 25
    readonly property int wifiSignalMedium: 50
    readonly property int wifiSignalHigh: 75
    readonly property string passwordPlaceholder: "Password"
    readonly property string emptyNoWifiDevice: "No Wi-Fi adapter"
    readonly property string emptyWifiDisabled: "Wi-Fi is off"
    readonly property string emptyScanning: "Scanning..."
    readonly property string emptyNoBluetooth: "No Bluetooth adapter"
    readonly property string emptyBluetoothDisabled: "Bluetooth is off"
    readonly property string emptyNoDevices: "No devices"
    readonly property string labelOutput: "Output"
    readonly property string labelInput: "Input"
    readonly property string labelStreams: "Applications"
    readonly property string labelNetwork: "Network"
    readonly property string labelBluetooth: "Bluetooth"
    readonly property string labelAudio: "Audio"
    readonly property string labelConnecting: "Connecting..."
    readonly property string labelConnected: "Connected"
    readonly property string labelSaved: "Saved"
    readonly property string labelPairing: "Pairing..."
    readonly property string labelAvailable: "Available"
    readonly property string labelBattery: "Battery"
    readonly property string labelAdapter: "Adapter"
    readonly property string labelOpen: "Open"
    readonly property string rssiTemplate: "%1 dBm"
    readonly property string detailSeparator: "  \u00b7  "
    readonly property string labelForgetConfirm: "Confirm"
    readonly property string failureNoSecrets: "Wrong password"
    readonly property string failureAuthTimeout: "Authentication timed out"
    readonly property string failureNetworkLost: "Network out of range"
    readonly property string failureDisconnected: "Disconnected"
    readonly property string failureGeneric: "Connection failed"
    readonly property string failureTimeout: "Connection timed out"
    readonly property int connectTimeout: 20000
    readonly property int scanIconSize: 16
    readonly property int scanSpinDuration: 1200
    readonly property int scanBlip: 250
    readonly property int scanBusy: 4000
}
