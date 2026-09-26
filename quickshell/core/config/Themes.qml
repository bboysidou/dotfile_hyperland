pragma Singleton

import Quickshell

Singleton {
    readonly property string black: "#000000"

    readonly property var monochrome: ({
            bg: "#000000",
            bgAlt: "#161616",
            bgLight: "#242424",
            bgLighter: "#383838",
            bgSelection: "#4A4A4A",
            bgHover: "#2E2E2E",
            fg: "#D0D0D0",
            fgMuted: "#7A7A7A",
            fgBright: "#FFFFFF",
            fgDim: "#5A5A5A",
            accent: "#F2F2F2",
            red: "#FFFFFF",
            green: "#BDBDBD",
            yellow: "#E0E0E0",
            blue: "#A8A8A8",
            magenta: "#8F8F8F",
            cyan: "#C8C8C8",
            orange: "#B0B0B0",
            border: "#333333",
            borderActive: "#F2F2F2",
            warning: "#E0E0E0",
            critical: "#FFFFFF",
            success: "#BDBDBD"
        })

    readonly property var hacker: ({
            bg: "#000000",
            bgAlt: "#061312",
            bgLight: "#0B211F",
            bgLighter: "#12342F",
            bgSelection: "#0E4A44",
            bgHover: "#0A2825",
            fg: "#5EEAD4",
            fgMuted: "#2A9D8F",
            fgBright: "#CCFBF1",
            fgDim: "#1B6F66",
            accent: "#14F1D9",
            red: "#FF3B30",
            green: "#2DD4BF",
            yellow: "#A7F3D0",
            blue: "#22D3EE",
            magenta: "#67E8F9",
            cyan: "#14F1D9",
            orange: "#FFB000",
            border: "#0F3B37",
            borderActive: "#14F1D9",
            warning: "#FFB000",
            critical: "#FF3B30",
            success: "#2DD4BF"
        })
}
