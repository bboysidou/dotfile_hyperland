import QtQuick
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
