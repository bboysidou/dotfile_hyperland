pragma Singleton

import Quickshell

Singleton {
    readonly property string fallback: "kitty"
    readonly property var namePattern: /return\s+"([^"]+)"/
    readonly property var unknown: ({
            exec: ["-e"],
            title: [],
            hold: []
        })
    readonly property var flags: ({
            kitty: {
                exec: [],
                title: ["--title", "%1"],
                hold: ["--hold"]
            },
            foot: {
                exec: [],
                title: ["--title", "%1"],
                hold: ["--hold"]
            },
            alacritty: {
                exec: ["-e"],
                title: ["--title", "%1"],
                hold: ["--hold"]
            },
            ghostty: {
                exec: ["-e"],
                title: ["--title=%1"],
                hold: ["--wait-after-command"]
            }
        })
}
