pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string cache: Quickshell.env("XDG_CACHE_HOME") || `${root.home}/.cache`
    readonly property string state: Quickshell.env("XDG_STATE_HOME") || `${root.home}/.local/state`
    readonly property string config: Quickshell.env("XDG_CONFIG_HOME") || `${root.home}/.config`
    readonly property string keymaps: `${root.config}/hypr/config/keymaps.lua`
    readonly property string terminal: `${root.config}/hypr/config/terminal.lua`
    readonly property string input: `${root.config}/hypr/config/input.lua`
    readonly property string monitors: `${root.config}/hypr/monitors.lua`
    readonly property string workspaces: `${root.config}/hypr/workspaces.lua`
    readonly property string vinyl: `${Quickshell.shellDir}/media/images/vinyl.png`
    readonly property string hwinfo: "/run/qs-hw"
    readonly property string powerSupply: "/sys/class/power_supply"
    readonly property string dimms: `${root.hwinfo}/dimms.tsv`
    readonly property string cpuPower: `${root.hwinfo}/cpu_power`

    function basename(path: string): string {
        return path.slice(path.lastIndexOf("/") + 1);
    }

    function extension(path: string): string {
        const dot = path.lastIndexOf(".");
        return dot === -1 ? "" : path.slice(dot + 1).toLowerCase();
    }
}
