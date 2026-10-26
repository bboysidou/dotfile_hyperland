import QtQuick

QtObject {
    readonly property int width: 1100
    readonly property int padding: 28
    readonly property int rounding: 28
    readonly property real scaleFrom: 0.96
    readonly property int sectionSpacing: 24
    readonly property int chipSpacing: 8
    readonly property int chipHeight: 30
    readonly property int chipPadding: 14
    readonly property int chipSize: 12
    readonly property int gridColumns: 2
    readonly property int gridSpacing: 10
    readonly property int gridRowStep: 2
    readonly property int tileHeight: 52
    readonly property int tilePadding: 14
    readonly property int tileRounding: 12
    readonly property int tileBorder: 2
    readonly property int tileNameSize: 14
    readonly property int tileSizeSize: 11
    readonly property int tickSize: 11
    readonly property int sliderTopMargin: 8
    readonly property int tickTopMargin: 10
    readonly property int buttonHeight: 46
    readonly property int buttonPadding: 26
    readonly property int buttonIconSize: 18
    readonly property int buttonSpacing: 10
    readonly property int keepSeconds: 15
    readonly property int tickInterval: 1000
    readonly property int rateDecimals: 2
    readonly property string modeTemplate: "%1x%2"
    readonly property string labelApply: "Apply"
    readonly property string labelKeep: "Keep"
    readonly property string labelRevert: "Revert"
    readonly property string keepTemplate: "Keep this display? Reverting in %1 s"
    readonly property string labelEmpty: "No monitor information from Hyprland."
    readonly property int canvasHeight: 260
    readonly property int canvasPadding: 24
    readonly property int canvasRounding: 16
    readonly property int canvasMonitorRounding: 8
    readonly property int canvasNameSize: 13
    readonly property int canvasDetailSize: 10
    readonly property int canvasBorder: 2
    readonly property real canvasDisabledOpacity: 0.35
    readonly property int snapDistance: 120
    readonly property int canvasBezel: 6
    readonly property int canvasStandWidth: 16
    readonly property int canvasStandHeight: 14
    readonly property real canvasBaseRatio: 0.35
    readonly property int canvasBaseHeight: 4
    readonly property int canvasToggleMargin: 14
    readonly property int canvasToggleSpacing: 8
    readonly property string labelBezels: "Bezels"
    readonly property int tabHeight: 330
    readonly property int rowHeight: 40
    readonly property int labelWidth: 150
    readonly property int stepperWidth: 84
    readonly property int positionStep: 10
    readonly property real sdrStep: 0.05
    readonly property real sdrMin: 0.5
    readonly property real sdrMax: 3
    readonly property real scaleTolerance: 0.01
    readonly property int workspaceCount: 10
    readonly property int workspaceTileSize: 56
    readonly property int workspaceColumns: 5
    readonly property string defaultCm: "srgb"
    readonly property var hdrPresets: ["hdr", "hdredid"]
    readonly property var scales: [1, 1.25, 1.333333, 1.5, 1.6, 1.666667, 1.75, 2, 2.5, 3]
    readonly property var transforms: [
        ["normal", 0], ["90\u00b0", 1], ["180\u00b0", 2], ["270\u00b0", 3],
        ["flipped", 4], ["flipped 90\u00b0", 5], ["flipped 180\u00b0", 6], ["flipped 270\u00b0", 7]
    ]
    readonly property var vrrModes: [["Off", 0], ["On", 1], ["Fullscreen", 2], ["Video / game", 3]]
    readonly property var bitdepths: [["8 bit", 8], ["10 bit", 10]]
    readonly property var cmPresets: ["auto", "srgb", "dcip3", "dp3", "adobe", "wide", "edid", "hdr", "hdredid"]
    readonly property string tabMode: "mode"
    readonly property string tabLayout: "layout"
    readonly property string tabColor: "color"
    readonly property string tabWorkspaces: "workspaces"
    readonly property string tabIdle: "idle"
    readonly property string labelModeTab: "Mode"
    readonly property string labelLayoutTab: "Layout"
    readonly property string labelColorTab: "Color"
    readonly property string labelWorkspacesTab: "Workspaces"
    readonly property string labelIdleTab: "Idle"
    readonly property string labelActive: "Active"
    readonly property string labelPosition: "Position"
    readonly property string labelScale: "Scale"
    readonly property string labelTransform: "Transform"
    readonly property string labelMirror: "Mirror"
    readonly property string labelMirrorNone: "None"
    readonly property string labelVrr: "Adaptive sync"
    readonly property string labelBitdepth: "Bit depth"
    readonly property string labelCm: "Color preset"
    readonly property string labelSdrBrightness: "SDR brightness"
    readonly property string labelSdrSaturation: "SDR saturation"
    readonly property string labelDpms: "Screen power (now)"
    readonly property string labelWorkspacesHint: "Click a workspace to move it to %1. The lowest one is its default."
    readonly property string labelDisabled: "disabled"
    readonly property string labelMirrored: "mirrors %1"
    readonly property string labelLastActive: "At least one monitor must stay active."
    readonly property string positionTemplate: "%1, %2"
    readonly property string scaleTemplate: "%1\u00d7"
    readonly property string detailTemplate: "%1x%2 @ %3Hz \u00b7 %4\u00d7"
    readonly property string dpmsTemplate: 'hl.dispatch(hl.dsp.dpms({ monitor = "%1", action = "%2" }))'
    readonly property string fallbackLine: 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })'
    readonly property string monitorsHeader: "-- Monitors (written by the Quickshell display panel, ALT + D)\n"
    readonly property string workspacesTemplate: "-- Workspaces (written by the Quickshell display panel, ALT + D)\n-- Entry N is the monitor workspace N lives on; the first workspace of each monitor is its default.\n\nlocal assignment = {\n%1\n}\n\nlocal seen = {}\nfor workspace, output in ipairs(assignment) do\n\thl.workspace_rule({ workspace = tostring(workspace), monitor = output, default = not seen[output] })\n\tseen[output] = true\nend\n\nreturn assignment\n"
    readonly property var names: ({
            "7680x4320": "8K",
            "5120x2880": "5K",
            "3840x2160": "4K",
            "3440x1440": "UWQHD",
            "2560x1600": "WQXGA",
            "2560x1440": "QHD",
            "2560x1080": "UW-FHD",
            "1920x1200": "WUXGA",
            "1920x1080": "FHD",
            "1680x1050": "WSXGA+",
            "1600x900": "HD+",
            "1440x900": "WXGA+",
            "1366x768": "WXGA",
            "1280x1024": "SXGA",
            "1280x800": "WXGA",
            "1280x720": "HD",
            "1024x768": "XGA",
            "800x600": "SVGA",
            "720x576": "PAL",
            "720x480": "NTSC",
            "640x480": "VGA"
        })
}
