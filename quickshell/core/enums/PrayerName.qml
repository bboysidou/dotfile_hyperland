pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string fajr: "fajr"
    readonly property string sunrise: "sunrise"
    readonly property string dhuhr: "dhuhr"
    readonly property string asr: "asr"
    readonly property string maghrib: "maghrib"
    readonly property string isha: "isha"

    readonly property var values: [root.fajr, root.sunrise, root.dhuhr, root.asr, root.maghrib, root.isha]
    readonly property var alerting: [root.fajr, root.dhuhr, root.asr, root.maghrib, root.isha]

    readonly property var labels: ({
            fajr: "Fajr",
            sunrise: "Shurūq",
            dhuhr: "Dhuhr",
            asr: "Asr",
            maghrib: "Maghrib",
            isha: "Isha"
        })
}
