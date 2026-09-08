pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property var methods: [
        {
            id: "mwl",
            label: "Muslim World League",
            fajr: 18,
            isha: 17,
            ishaMinutes: 0
        },
        {
            id: "algeria",
            label: "Algeria (Ministry)",
            fajr: 18,
            isha: 17,
            ishaMinutes: 0
        },
        {
            id: "isna",
            label: "ISNA (North America)",
            fajr: 15,
            isha: 15,
            ishaMinutes: 0
        },
        {
            id: "egypt",
            label: "Egyptian Authority",
            fajr: 19.5,
            isha: 17.5,
            ishaMinutes: 0
        },
        {
            id: "makkah",
            label: "Umm al-Qura",
            fajr: 18.5,
            isha: 0,
            ishaMinutes: 90
        },
        {
            id: "karachi",
            label: "Karachi",
            fajr: 18,
            isha: 18,
            ishaMinutes: 0
        }
    ]

    readonly property var asrSchools: [
        {
            id: "standard",
            label: "Standard",
            factor: 1
        },
        {
            id: "hanafi",
            label: "Hanafi",
            factor: 2
        }
    ]

    readonly property var highLatRules: [
        {
            id: "angle",
            label: "Angle"
        },
        {
            id: "midnight",
            label: "Midnight"
        },
        {
            id: "seventh",
            label: "Seventh"
        },
        {
            id: "none",
            label: "None"
        }
    ]

    readonly property var fallbackPlace: ({
            lat: 35.3711,
            lon: 1.3170,
            city: "Tiaret",
            country: "DZ",
            tz: "Africa/Algiers"
        })

    readonly property string geoEndpoint: "https://ipwho.is/"
    readonly property string searchEndpoint: "https://geocoding-api.open-meteo.com/v1/search?name=%1&count=%2&format=json"

    readonly property string defaultMethod: "mwl"
    readonly property string defaultAsr: "standard"
    readonly property string defaultHighLat: "angle"
    readonly property real defaultIshaAngle: 18
}
