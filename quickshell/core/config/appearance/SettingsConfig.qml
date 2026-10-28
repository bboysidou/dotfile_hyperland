import QtQuick
import Quickshell.Services.Notifications
import qs.core.enums

QtObject {
    readonly property int width: 440
    readonly property int listSpacing: 8
    readonly property int cardPadding: 12
    readonly property int cardRounding: 12
    readonly property int cardSpacing: 8
    readonly property int headerSpacing: 14
    readonly property int iconSize: 22
    readonly property int iconWidth: 28
    readonly property int commandHeight: 28
    readonly property int commandPaddingH: 10
    readonly property int commandRounding: 8
    readonly property int commandSpacing: 4
    readonly property int commandLabelWidth: 48
    readonly property int commandIconSize: 14
    readonly property int pollInterval: 3000
    readonly property int copiedTimeout: 1500
    readonly property string tabServices: "services"
    readonly property string title: "Settings"
    readonly property string labelServicesTab: "Services"
    readonly property string hintServices: "Switches act now. Click a command to copy it for a terminal."
    readonly property string labelEnable: "Enable"
    readonly property string labelKill: "Kill"
    readonly property string labelInstall: "Install"
    readonly property string labelCopied: "Copied"
    readonly property string stateRunning: "running"
    readonly property string stateStopped: "stopped"
    readonly property string stateEnabled: "starts at boot"
    readonly property string stateDisabled: "off at boot"
    readonly property string stateStatic: "started on demand"
    readonly property string stateMissing: "not installed"
    readonly property string stateBusy: "working…"
    readonly property string stateFailed: "failed (exit %1)"
    readonly property string stateSeparator: "  ·  "
    readonly property string tabGeneral: "general"
    readonly property string labelGeneralTab: "General"
    readonly property string stateFile: "settings.json"
    readonly property int saveDebounce: 400
    readonly property int sectionTitleSize: 12
    readonly property int rowHeight: 34
    readonly property int stepperWidth: 72
    readonly property int pickLimit: 8
    readonly property int pickSpacing: 6
    readonly property string labelBar: "Bar"
    readonly property string labelNotifications: "Notifications"
    readonly property string labelLook: "Look"
    readonly property string labelWorldClocks: "World clocks"
    readonly property string labelKeyboard: "Keyboard"
    readonly property string labelMouse: "Mouse"
    readonly property string labelTouchpad: "Touchpad"
    readonly property string labelNever: "Never"
    readonly property string labelOff: "Off"
    readonly property string labelWeather: "Weather"
    readonly property string labelSystem: "System"
    readonly property string labelClipboard: "Clipboard"
    readonly property string labelClipMaxItems: "Keep up to"
    readonly property string labelClipImages: "Save images"
    readonly property string labelClipMaxAge: "Delete entries after"
    readonly property string labelClipClear: "Clear history (%1)"
    readonly property string labelClear: "Clear"
    readonly property string labelConfirm: "Sure?"
    readonly property string labelHistoryDays: "Keep history for"
    readonly property string labelHistoryMax: "History holds up to"
    readonly property string labelMaxPopups: "Popups at once"
    readonly property string labelBarClock: "Bar clock"
    readonly property string labelTempUnit: "Temperature"
    readonly property string labelWindUnit: "Wind speed"
    readonly property string labelUpdateCheck: "Check for updates"
    readonly property string labelMouseWarn: "Warn when mouse is at"
    readonly property string daysTemplate: "%1 d"
    readonly property string labelFont: "UI font"
    readonly property string labelTextSize: "Text size"
    readonly property string labelPanelOutline: "Panel outline"
    readonly property string labelReset: "Reset"
    readonly property string labelLayouts: "Layouts"
    readonly property string labelVariant: "Variant"
    readonly property string labelSwitchKey: "Switch with"
    readonly property string labelSensitivity: "Sensitivity"
    readonly property string labelFlatAccel: "Flat acceleration"
    readonly property string labelNaturalScroll: "Natural scroll"
    readonly property string labelTapToClick: "Tap to click"
    readonly property string labelDisableWhileTyping: "Off while typing"
    readonly property string labelDefaultVariant: "default"
    readonly property string placeholderFont: "Search installed fonts"
    readonly property string placeholderZone: "Add a city or timezone"
    readonly property string placeholderLayout: "Add a keyboard layout"
    readonly property string hintNoTouchpad: "No touchpad detected. Settings apply when one is connected."
    readonly property string hintClocksFull: "Remove a clock to add another."
    readonly property string secondsTemplate: "%1 s"
    readonly property string percentTemplate: "%1%"
    readonly property string sensitivityTemplate: "%1"
    readonly property int timeoutMin: 0
    readonly property int timeoutMax: 60000
    readonly property int timeoutStep: 1000
    readonly property real scaleMin: 0.8
    readonly property real scaleMax: 1.5
    readonly property real scaleStep: 0.05
    readonly property real sensitivityMin: -1
    readonly property real sensitivityMax: 1
    readonly property real sensitivityStep: 0.1
    readonly property int sensitivityDecimals: 1
    readonly property int maxClocks: 5
    readonly property int countStep: 1
    readonly property int historyDaysMin: 1
    readonly property int historyDaysMax: 30
    readonly property int historyMaxMin: 20
    readonly property int historyMaxMax: 500
    readonly property int historyMaxStep: 20
    readonly property int popupsMin: 1
    readonly property int popupsMax: 6
    readonly property int mouseWarnMin: 0
    readonly property int mouseWarnMax: 50
    readonly property int mouseWarnStep: 5
    readonly property int segmentWidth: 210
    readonly property int clipItemsMin: 50
    readonly property int clipItemsMax: 1000
    readonly property int clipItemsStep: 50
    readonly property int confirmTimeout: 3000
    readonly property var clipAgeChoices: [
        {
            key: "0",
            label: "Never"
        },
        {
            key: "1",
            label: "1d"
        },
        {
            key: "7",
            label: "7d"
        },
        {
            key: "30",
            label: "30d"
        },
        {
            key: "90",
            label: "90d"
        }
    ]
    readonly property var barClockFormats: [
        {
            key: "ddd, dd. MMM HH:mm",
            label: "Full"
        },
        {
            key: "dd/MM HH:mm",
            label: "Short"
        },
        {
            key: "HH:mm",
            label: "Time"
        }
    ]
    readonly property var updateChoices: [
        {
            key: "0",
            label: "Off"
        },
        {
            key: "15",
            label: "15m"
        },
        {
            key: "30",
            label: "30m"
        },
        {
            key: "60",
            label: "1h"
        },
        {
            key: "180",
            label: "3h"
        }
    ]
    readonly property int maxLayouts: 4
    readonly property string flatProfile: "flat"
    readonly property string touchpadMatch: "touchpad"
    readonly property var switchKeys: [["Alt+Shift", "grp:alt_shift_toggle"], ["Ctrl+Shift", "grp:ctrl_shift_toggle"], ["Super+Space", "grp:win_space_toggle"], ["Caps Lock", "grp:caps_toggle"]]
    readonly property var urgencyLabels: [[NotificationUrgency.Low, "Low priority"], [NotificationUrgency.Normal, "Normal"], [NotificationUrgency.Critical, "Critical"]]
    readonly property string inputHeader: "-- Input (written by the Quickshell settings panel, ALT + S)\n-- https://wiki.hypr.land/Configuring/Basics/Variables/\n\n"
    readonly property string inputTemplate: "hl.config({\n    input = {\n        kb_layout  = \"%1\",\n        kb_variant = \"%2\",\n        kb_model   = \"\",\n        kb_options = \"%3\",\n\n        follow_mouse       = 2,\n        numlock_by_default = true,\n        sensitivity        = %4,\n        accel_profile      = \"%5\",\n        natural_scroll     = %6,\n        touchpad = {\n            natural_scroll       = %7,\n            tap_to_click         = %8,\n            disable_while_typing = %9,\n        },\n    },\n})\n"
    readonly property var services: [
        {
            id: "hwinfo",
            kind: ServiceKind.system,
            unit: "qs-hwinfo.service",
            installable: true,
            glyph: "memory",
            title: "Hardware info",
            description: "Root helper for the hardware sheet: RAM module details and CPU package power."
        },
        {
            id: "sharePicker",
            kind: ServiceKind.flag,
            unit: "share-picker.off",
            installable: false,
            glyph: "shareScreen",
            title: "Screen share picker",
            description: "Quickshell picker for screen sharing. Off falls back to hyprland-share-picker."
        },
        {
            id: "audioFilters",
            kind: ServiceKind.user,
            unit: "filter-chain.service",
            installable: false,
            glyph: "equalizer",
            title: "Equalizer & echo cancellation",
            description: "PipeWire filter chain behind the EQ tab and the microphone echo cancel."
        },
        {
            id: "tmux",
            kind: ServiceKind.user,
            unit: "tmux.service",
            installable: false,
            glyph: "terminal",
            title: "tmux server",
            description: "Background tmux server, so sessions survive closing the terminal."
        },
        {
            id: "sshAgent",
            kind: ServiceKind.user,
            unit: "gcr-ssh-agent.socket",
            installable: false,
            glyph: "key",
            title: "SSH agent",
            description: "GNOME keyring SSH agent socket, unlocked with the login password."
        }
    ]
}
