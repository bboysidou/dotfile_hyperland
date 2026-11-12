pragma Singleton

import Quickshell

// Shared location configuration. No dependency on Prayer Times.
Singleton {
    readonly property var fallbackPlace: ({ lat: 35.3711, lon: 1.3170, city: "Tiaret", country: "DZ", tz: "Africa/Algiers" })
    readonly property string geoEndpoint: "https://ipwho.is/"
    readonly property string searchEndpoint: "https://geocoding-api.open-meteo.com/v1/search?name=%1&count=%2&format=json"
    readonly property int searchMinLength: 2
    readonly property int searchMaxResults: 5
    readonly property int searchDebounce: 350
    readonly property int requestTimeout: 8
    readonly property int saveDebounce: 500
    readonly property string sourcePinned: "Pinned"
    readonly property string sourceDetected: "Detected"
    readonly property string sourceCached: "Cached"
    readonly property string sourceFallback: "Default"
}
