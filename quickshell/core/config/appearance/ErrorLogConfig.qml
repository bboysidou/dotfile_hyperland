import QtQuick

QtObject {
    readonly property string stateFile: "errorlog.json"
    readonly property string crashDir: "quickshell/crashes"
    readonly property int maxEntries: 300
    readonly property int publishDelay: 250
    readonly property int restartDelay: 5000
    readonly property int collapsedLines: 3
    readonly property int expandedLines: 200
    readonly property int stripeWidth: 3
    readonly property int metaSpacing: 6
    readonly property int toolbarSpacing: 8
    readonly property int copiedTimeout: 1500
    readonly property string timeFormat: "dd/MM HH:mm:ss"
    readonly property string countTemplate: "×%1"
    readonly property string tabTemplate: "%1 · %2"
    readonly property string copyLineTemplate: "[%1] %2 %3: %4"
    readonly property string copyCountTemplate: " (×%1)"
    readonly property string tabKey: "errors"
    readonly property string labelTab: "Errors"
    readonly property string labelCopyAll: "Copy"
    readonly property string labelCopied: "Copied"
    readonly property string labelClear: "Clear"
    readonly property string labelConfirm: "Sure?"
    readonly property string exitTemplate: "%1 exited with code %2"
    readonly property string crashFallback: "Quickshell crashed"
    readonly property string crashSource: "crash report"
    readonly property string hint: "Shell warnings, errors and crashes since the last clear. Click an entry to expand it."
    readonly property string emptyTitle: "No errors"
    readonly property string emptySubtitle: "Nothing has gone wrong since the last clear"
    readonly property string filterAll: "all"
    readonly property string filterErrors: "errors"
    readonly property string filterWarnings: "warnings"
    readonly property string labelAll: "All"
    readonly property string labelErrors: "Errors"
    readonly property string labelWarnings: "Warnings"
}
