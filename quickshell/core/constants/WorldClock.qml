pragma Singleton

import Quickshell

Singleton {
    readonly property var zones: [
        {
            label: "Montreal",
            zone: "America/Montreal"
        },
        {
            label: "Alberta",
            zone: "America/Edmonton"
        },
        {
            label: "San Francisco",
            zone: "America/Los_Angeles"
        }
    ]
}
