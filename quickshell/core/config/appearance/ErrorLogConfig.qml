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
    readonly property string hyprlandSource: "Hyprland"
    readonly property string hyprlandLogTemplate: "%1/hypr/%2/hyprland.log"
    readonly property int hyprlandContextLines: 20
    readonly property string hyprlandVersionMark: "V"
    readonly property string hyprlandContextMark: "C"
    readonly property string hyprlandEntryMark: "E"
    readonly property string hyprlandCoreLabel: "Hyprland core"
    readonly property string hyprlandNoStamp: "not logged, estimated from the nearest stamped line"
    readonly property string hyprlandOriginTemplate: "Origin: %1"
    readonly property string hyprlandCallTemplate: "Call: %1"
    readonly property string hyprlandStampTemplate: "Logged at: %1"
    readonly property string hyprlandVersionTemplate: "Version: %1"
    readonly property string hyprlandSessionTemplate: "Session: %1"
    readonly property string hyprlandFileTemplate: "Log file: %1:%2"
    readonly property string hyprlandContextTemplate: "Preceding log lines (%1):"
    readonly property string hint: "Shell and Hyprland warnings, errors and crashes since the last clear. Click an entry to expand it."
    readonly property string emptyTitle: "No errors"
    readonly property string emptySubtitle: "Nothing has gone wrong since the last clear"
    readonly property string filterAll: "all"
    readonly property string filterErrors: "errors"
    readonly property string filterWarnings: "warnings"
    readonly property string labelAll: "All"
    readonly property string labelErrors: "Errors"
    readonly property string labelWarnings: "Warnings"
}
