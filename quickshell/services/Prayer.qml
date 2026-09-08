pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers

Singleton {
    id: root

    property bool loaded: false
    property var pinned: null
    property var cached: null
    property string method: Prayers.defaultMethod
    property string asr: Prayers.defaultAsr
    property string highLat: Prayers.defaultHighLat

    readonly property string stateDir: `${Paths.state}/${Appearance.prayer.stateDir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.prayer.stateFile}`

    readonly property var place: root.pinned ?? Geo.detected ?? root.cached ?? Prayers.fallbackPlace

    readonly property string source: {
        if (root.pinned)
            return Appearance.prayer.sourcePinned;
        if (Geo.detected)
            return Appearance.prayer.sourceDetected;
        if (root.cached)
            return Appearance.prayer.sourceCached;
        return Appearance.prayer.sourceFallback;
    }

    readonly property var methodConfig: Prayers.methods.find(entry => entry.id === root.method) ?? Prayers.methods[0]
    readonly property real asrFactor: (Prayers.asrSchools.find(entry => entry.id === root.asr) ?? Prayers.asrSchools[0]).factor

    readonly property int systemZoneOffset: -Time.now.getTimezoneOffset()
    readonly property real placeZoneOffset: Geo.offsetFor(root.place.tz)
    readonly property bool zoneMismatch: !isNaN(root.placeZoneOffset) && root.placeZoneOffset !== root.systemZoneOffset

    readonly property var today: root.compute(0)
    readonly property var schedule: root.compute(-1).concat(root.today).concat(root.compute(1)).filter(entry => entry.date !== null).sort((a, b) => a.date.getTime() - b.date.getTime())

    readonly property var current: {
        const past = root.schedule.filter(entry => entry.date <= Time.now);
        return past.length > 0 ? past[past.length - 1] : null;
    }

    readonly property var next: root.schedule.find(entry => entry.alerting && entry.date > Time.now) ?? null

    readonly property int minutesToNext: root.next ? Math.max(0, Math.round((root.next.date.getTime() - Time.now.getTime()) / Units.msPerMinute)) : -1
    readonly property bool urgent: root.minutesToNext >= 0 && root.minutesToNext <= Appearance.prayer.urgentWindow

    readonly property string countdown: {
        if (root.minutesToNext < 0)
            return Appearance.prayer.placeholder;

        const hours = Math.floor(root.minutesToNext / Units.minutesPerHour);
        const minutes = root.minutesToNext % Units.minutesPerHour;

        return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
    }

    readonly property real progress: {
        if (!root.current || !root.next)
            return 0;

        const span = root.next.date.getTime() - root.current.date.getTime();
        if (span <= 0)
            return 0;

        return Num.clamp01((Time.now.getTime() - root.current.date.getTime()) / span);
    }

    function compute(delta: int): var {
        const anchor = Time.now;
        const base = new Date(anchor.getFullYear(), anchor.getMonth(), anchor.getDate() + delta);
        const noon = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 12);
        const raw = Solar.timesFor({
            year: base.getFullYear(),
            month: base.getMonth() + 1,
            day: base.getDate(),
            lat: root.place.lat,
            lon: root.place.lon,
            elevation: 0,
            tzHours: -noon.getTimezoneOffset() / Units.minutesPerHour,
            fajrAngle: root.methodConfig.fajr,
            ishaAngle: root.methodConfig.isha,
            ishaMinutes: root.methodConfig.ishaMinutes,
            asrFactor: root.asrFactor,
            highLat: root.highLat
        });

        return PrayerName.values.map(name => {
            const hours = raw[name];
            const known = !isNaN(hours);
            const whole = known ? Math.floor(hours) : 0;
            const date = known ? new Date(base.getFullYear(), base.getMonth(), base.getDate(), whole, Math.round((hours - whole) * Units.minutesPerHour)) : null;

            return {
                name: name,
                label: PrayerName.labels[name],
                date: date,
                time: date ? Qt.formatDateTime(date, Appearance.prayer.timeFormat) : Appearance.prayer.placeholder,
                alerting: PrayerName.alerting.indexOf(name) !== -1
            };
        });
    }

    function pin(place: var): void {
        root.pinned = place;
        root.persist();
    }

    function unpin(): void {
        root.pinned = null;
        root.persist();
    }

    function setMethod(id: string): void {
        root.method = id;
        root.persist();
    }

    function setAsr(id: string): void {
        root.asr = id;
        root.persist();
    }

    function setHighLat(id: string): void {
        root.highLat = id;
        root.persist();
    }

    function adopt(payload: string): void {
        try {
            const data = JSON.parse(payload);

            root.pinned = data.pinned ?? null;
            root.cached = data.cached ?? null;
            root.method = data.method ?? Prayers.defaultMethod;
            root.asr = data.asr ?? Prayers.defaultAsr;
            root.highLat = data.highLat ?? Prayers.defaultHighLat;
        } catch (parseError) {
            root.pinned = null;
        }

        root.loaded = true;
    }

    function persist(): void {
        if (root.loaded)
            debounce.restart();
    }

    function flush(): void {
        store.setText(JSON.stringify({
            pinned: root.pinned,
            cached: root.cached,
            method: root.method,
            asr: root.asr,
            highLat: root.highLat
        }));
    }

    onPlaceChanged: Geo.requestZone(root.place.tz)

    Component.onCompleted: Geo.requestZone(root.place.tz)

    Connections {
        target: Geo

        function onDetectedChanged(): void {
            if (!Geo.detected)
                return;

            root.cached = Geo.detected;
            root.persist();
        }
    }

    Timer {
        id: debounce

        interval: Appearance.prayer.saveDebounce

        onTriggered: root.flush()
    }

    Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: store

        path: root.statePath
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
        onLoadFailed: root.loaded = true
    }
}
