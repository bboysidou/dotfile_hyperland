import QtQuick

QtObject {
    readonly property string nodeName: "effect_input.quickshell-eq"
    readonly property string paramTemplate: "\"eq_band_%1:Gain\" %2"
    readonly property string propsTemplate: "{ params = [ %1 ] }"
    readonly property string stateFile: "equalizer.json"
    readonly property var frequencies: [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    readonly property var labels: ["31", "63", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"]
    readonly property real gainMin: -12
    readonly property real gainMax: 12
    readonly property real gainStep: 0.5
    readonly property int applyDebounce: 60
    readonly property int saveDebounce: 500
    readonly property int sliderHeight: 170
    readonly property int sliderWidth: 6
    readonly property int handleSize: 16
    readonly property int bandLabelSize: 10
    readonly property int bandSpacing: 4
    readonly property int presetColumns: 4
    readonly property int presetHeight: 34
    readonly property int presetSpacing: 6
    readonly property int presetRounding: 8
    readonly property int presetSize: 12
    readonly property int sectionSpacing: 14
    readonly property int titleSize: 15
    readonly property int badgeSize: 11
    readonly property int badgePadding: 10
    readonly property int badgeHeight: 22
    readonly property string labelTitle: "Equalizer"
    readonly property string labelSaved: "Saved"
    readonly property string labelCustom: "Custom"
    readonly property string labelMissing: "Equalizer is not running. Enable it with: systemctl --user enable --now filter-chain"
    readonly property var presets: [
        ["Flat", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]],
        ["Bass", [6, 5, 4, 2, 0, 0, 0, 0, 0, 0]],
        ["Treble", [0, 0, 0, 0, 0, 1, 2, 4, 5, 6]],
        ["Vocal", [-2, -2, -1, 1, 3, 4, 3, 1, 0, -1]],
        ["Pop", [-1, 1, 3, 4, 3, 0, -1, -1, 1, 2]],
        ["Rock", [5, 4, 2, -1, -2, -1, 1, 3, 4, 5]],
        ["Jazz", [3, 2, 1, 2, -1, -1, 0, 1, 2, 3]],
        ["Classic", [4, 3, 2, 1, -1, -1, 0, 2, 3, 4]]
    ]
}
