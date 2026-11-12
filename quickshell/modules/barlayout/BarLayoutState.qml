pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string selected: ""

    readonly property var labels: Appearance.bar.entryLabels
    readonly property var managed: root.labels.map(entry => entry[0])
    readonly property var off: root.managed.filter(entry => !Prefs.barEnabled(entry))
    readonly property var board: root.managed.filter(entry => Prefs.barEnabled(entry))

    function show(): void {
        root.selected = "";
        root.opened = true;
    }

    function hide(): void {
        root.opened = false;
    }

    function toggle(): void {
        if (root.opened)
            root.hide();
        else
            root.show();
    }

    function label(entry: string): string {
        return root.labels.find(item => item[0] === entry)?.[1] ?? entry;
    }

    function locked(entry: string): bool {
        return Appearance.bar.lockedEntries.includes(entry);
    }

    function available(entry: string): bool {
        return entry !== BarEntry.prayers || Prefs.prayersEnabled;
    }

    function zoneEntries(zone: string): var {
        return Prefs.zoneOrder(zone).filter(entry => root.board.includes(entry));
    }

    function place(entry: string, zone: string, before: string): void {
        if (!root.available(entry))
            return;
        if (!Prefs.barEnabled(entry))
            Prefs.setBarEnabled(entry, true);
        Prefs.moveBarEntry(entry, zone, before);
    }

    function turnOff(entry: string): void {
        if (!root.locked(entry) && root.available(entry))
            Prefs.setBarEnabled(entry, false);
    }

    function toggleOff(entry: string): void {
        if (!root.locked(entry) && root.available(entry))
            Prefs.setBarEnabled(entry, !Prefs.barEnabled(entry));
    }

    function step(delta: int): void {
        const flat = BarZone.values.reduce((all, zone) => all.concat(root.zoneEntries(zone)), []).concat(root.off);
        if (flat.length === 0)
            return;
        const index = flat.indexOf(root.selected);
        root.selected = flat[index < 0 ? 0 : Num.wrap(index, delta, flat.length)];
    }

    function shift(delta: int): void {
        const entry = root.selected;
        if (!root.board.includes(entry))
            return;
        const zones = BarZone.values;
        const zone = Prefs.barZone(entry);
        const order = root.zoneEntries(zone).filter(item => item !== BarEntry.media);
        const index = order.indexOf(entry);
        const inside = entry !== BarEntry.media && index + delta >= 0 && index + delta < order.length;
        if (inside) {
            root.place(entry, zone, delta < 0 ? order[index - 1] : order[index + 2] ?? "");
            return;
        }
        const next = zones[zones.indexOf(zone) + delta];
        if (next)
            root.place(entry, next, delta > 0 ? root.zoneEntries(next)[0] ?? "" : "");
    }
}
