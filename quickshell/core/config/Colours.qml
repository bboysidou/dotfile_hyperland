pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var requiredKeys: ["bg", "bgAlt", "bgLight", "fg", "fgMuted", "fgBright", "accent", "warning", "critical", "green", "border"]

    readonly property var seed: ({
            bg: "#000000",
            bgAlt: "#1E1E1E",
            bgLight: "#2D2D2D",
            bgLighter: "#3E3E3E",
            bgSelection: "#264F78",
            bgHover: "#3A3D41",
            fg: "#D4D4D4",
            fgMuted: "#808080",
            fgBright: "#FFFFFF",
            fgDim: "#666666",
            accent: "#1793d0",
            red: "#F44747",
            green: "#4EC9B0",
            yellow: "#D7BA7D",
            blue: "#569CD6",
            magenta: "#C586C0",
            cyan: "#4EC9B0",
            orange: "#CE9178",
            border: "#404040",
            borderActive: "#569CD6",
            warning: "#fabd2f",
            critical: "#F44747",
            success: "#4EC9B0"
        })

    property var raw: seed

    readonly property real criticalTint: 0.16

    readonly property color surface: raw.bg
    readonly property color bar: raw.bg
    readonly property color pill: shade(raw.bgAlt, 0.5)
    readonly property color trough: shade(raw.bgLight, 0.7)
    readonly property color hover: raw.bgHover
    readonly property color text: raw.fg
    readonly property color textMuted: raw.fgMuted
    readonly property color textBright: raw.fgBright
    readonly property color highlight: raw.accent
    readonly property color accent: raw.accent
    readonly property color border: raw.border
    readonly property color warning: raw.warning
    readonly property color critical: raw.critical
    readonly property color media: raw.green
    readonly property color ringTrack: raw.bgLighter
    readonly property color urgencyCritical: raw.critical
    readonly property color criticalSurface: blend(pill, raw.critical, criticalTint)
    readonly property color cpu: raw.accent
    readonly property color memory: raw.green
    readonly property color gauge: shade(raw.fg, 0.78)
    readonly property color swap: raw.magenta
    readonly property color storage: raw.yellow
    readonly property color arch: raw.blue
    readonly property color netDown: raw.blue
    readonly property color netUp: raw.orange
    readonly property color temp: raw.orange
    readonly property color shadow: "#000000"

    function blend(base: color, over: color, ratio: real): color {
        return Qt.rgba(base.r + (over.r - base.r) * ratio, base.g + (over.g - base.g) * ratio, base.b + (over.b - base.b) * ratio, base.a);
    }

    function shade(c: color, factor: real): color {
        return Qt.hsla(c.hslHue, c.hslSaturation, Math.min(1, c.hslLightness * factor), c.a);
    }

    function isValid(candidate): bool {
        if (!candidate || typeof candidate !== "object")
            return false;

        return requiredKeys.every(key => typeof candidate[key] === "string" && candidate[key].startsWith("#"));
    }

    function apply(payload: string): void {
        let parsed;
        try {
            parsed = JSON.parse(payload);
        } catch (e) {
            console.warn("Colours: palette.json is not valid JSON, keeping previous palette");
            return;
        }

        if (!isValid(parsed)) {
            console.warn("Colours: palette.json is missing required keys, keeping previous palette");
            return;
        }

        root.raw = parsed;
    }

    FileView {
        path: `${Quickshell.shellDir}/core/config/palette.json`
        watchChanges: true

        onFileChanged: reload()
        onLoaded: root.apply(text())
        onLoadFailed: console.warn("Colours: could not read palette.json, using seed palette")
    }
}
