pragma Singleton

import QtQuick
import Quickshell
import qs.core.helpers
import qs.services

Singleton {
    id: root

    property var pins: []
    property int serial: 0

    function add(path: string): void {
        if (Lock.locked || !path)
            return;

        root.serial += 1;
        root.pins = [...root.pins, {
                id: root.serial,
                path: path,
                screen: Monitors.focused,
                slot: root.pins.length
            }];
    }

    function remove(id: int): void {
        root.pins = root.pins.filter(p => p.id !== id);
    }

    function clear(): void {
        root.pins = [];
    }
}
