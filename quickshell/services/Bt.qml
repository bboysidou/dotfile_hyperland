pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    property bool discovering: false

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false

    readonly property var devices: (Bluetooth.devices?.values ?? []).slice().sort((first, second) => {
        if (first.connected !== second.connected)
            return first.connected ? -1 : 1;
        if (first.paired !== second.paired)
            return first.paired ? -1 : 1;
        return first.name.localeCompare(second.name);
    })

    readonly property int connected: root.devices.filter(device => device.connected).length

    function setEnabled(value: bool): void {
        if (root.adapter)
            root.adapter.enabled = value;
    }

    function connectDevice(device): void {
        device?.connect();
    }

    function disconnectDevice(device): void {
        device?.disconnect();
    }

    function forgetDevice(device): void {
        device?.forget();
    }

    Binding {
        when: root.adapter !== null
        target: root.adapter
        property: "discovering"
        value: root.discovering
    }
}
