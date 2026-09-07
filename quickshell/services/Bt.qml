pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.core.config
import qs.core.constants

Singleton {
    id: root

    property bool discovering: false
    property string pendingPair: ""
    property bool pendingEnable: false
    property var connecting: null
    property var stalled: null

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
        if (!root.adapter)
            return;

        if (!value) {
            root.adapter.enabled = false;
            return;
        }

        root.pendingEnable = true;
        unblock.running = true;
    }

    function activateDevice(device): void {
        if (!device)
            return;

        if (device.connected) {
            root.endConnect();
            device.disconnect();
            return;
        }

        if (device.pairing) {
            root.pendingPair = "";
            root.setPairable(false);
            device.cancelPair();
            return;
        }

        if (!device.paired) {
            root.setPairable(true);
            root.pendingPair = device.address;
            device.pair();
            return;
        }

        root.beginConnect(device);
        device.connect();
    }

    function beginConnect(device): void {
        root.stalled = null;
        root.connecting = device;
        connectTimeout.restart();
    }

    function endConnect(): void {
        root.connecting = null;
        connectTimeout.stop();
    }

    function setPairable(value: bool): void {
        if (root.adapter)
            root.adapter.pairable = value;
    }

    function busy(device): bool {
        if (root.stalled === device)
            return false;

        return (device?.pairing ?? false) || device?.state === BluetoothDeviceState.Connecting || device?.state === BluetoothDeviceState.Disconnecting;
    }

    function failed(device): bool {
        return root.stalled === device;
    }

    function statusText(device): string {
        const control = Appearance.control;

        if (root.stalled === device)
            return control.failureTimeout;
        if (device?.pairing)
            return control.labelPairing;
        if (device?.state === BluetoothDeviceState.Connecting)
            return control.labelConnecting;
        if (device?.connected)
            return control.labelConnected;
        if (device?.paired)
            return control.labelSaved;

        return control.labelAvailable;
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

    Timer {
        id: connectTimeout

        interval: Appearance.control.connectTimeout

        onTriggered: {
            const device = root.connecting;
            root.connecting = null;

            if (!device || device.connected)
                return;

            root.stalled = device;
            device.disconnect();
        }
    }

    Process {
        id: unblock

        command: Commands.bluetoothUnblock

        onExited: {
            if (!root.pendingEnable)
                return;

            root.pendingEnable = false;

            if (root.adapter)
                root.adapter.enabled = true;
        }
    }

    Instantiator {
        model: root.devices

        delegate: QtObject {
            required property var modelData

            readonly property bool paired: modelData?.paired ?? false
            readonly property bool connected: modelData?.connected ?? false

            onConnectedChanged: {
                if (connected && root.connecting === modelData)
                    root.endConnect();
            }

            onPairedChanged: {
                if (root.pendingPair !== modelData.address)
                    return;

                if (!paired)
                    return;

                root.pendingPair = "";
                root.setPairable(false);
                root.beginConnect(modelData);
                modelData.connect();
            }
        }
    }

    Binding {
        when: root.adapter !== null
        target: root.adapter
        property: "discovering"
        value: root.discovering
    }
}
