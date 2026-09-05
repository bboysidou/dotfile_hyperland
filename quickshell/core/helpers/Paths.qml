pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string cache: Quickshell.env("XDG_CACHE_HOME") || `${root.home}/.cache`
    readonly property string state: Quickshell.env("XDG_STATE_HOME") || `${root.home}/.local/state`

    function basename(path: string): string {
        return path.slice(path.lastIndexOf("/") + 1);
    }

    function extension(path: string): string {
        const dot = path.lastIndexOf(".");
        return dot === -1 ? "" : path.slice(dot + 1).toLowerCase();
    }
}
