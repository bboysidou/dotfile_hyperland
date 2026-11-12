pragma Singleton

import Quickshell

// Passive facade: the module owns all calculations and alert processes.
Singleton {
    id: root

    property var backend: null
    property var alerts: null
    property var firedAlerts: ({})
    readonly property bool available: root.backend !== null
    readonly property var today: root.backend ? root.backend.today : []
    readonly property var schedule: root.backend ? root.backend.schedule : []
    readonly property var current: root.backend ? root.backend.current : null
    readonly property var next: root.backend ? root.backend.next : null
    readonly property int minutesToNext: root.backend ? root.backend.minutesToNext : -1
    readonly property string countdown: root.backend ? root.backend.countdown : "—"
    readonly property bool urgent: root.backend ? root.backend.urgent : false
    readonly property real progress: root.backend ? root.backend.progress : 0
    readonly property bool zoneMismatch: root.backend ? root.backend.zoneMismatch : false
    readonly property string method: root.backend ? root.backend.method : ""
    readonly property string asr: root.backend ? root.backend.asr : ""
    readonly property string highLat: root.backend ? root.backend.highLat : ""
    readonly property var methodConfig: root.backend ? root.backend.methodConfig : null
    readonly property real asrFactor: root.backend ? root.backend.asrFactor : 1
    readonly property var place: Location.place
    readonly property var pinned: Location.pinned
    readonly property string source: Location.source

    function pin(place: var): void { Location.pin(place); }
    function unpin(): void { Location.unpin(); }
    function setMethod(value: string): void { if (root.backend) root.backend.setMethod(value); }
    function setAsr(value: string): void { if (root.backend) root.backend.setAsr(value); }
    function setHighLat(value: string): void { if (root.backend) root.backend.setHighLat(value); }
}
