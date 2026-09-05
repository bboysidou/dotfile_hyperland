pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property bool scanning: false

    readonly property var devices: Networking.devices?.values ?? []
    readonly property var wifiDevices: root.devices.filter(device => device?.type === DeviceType.Wifi && device.scannerEnabled !== undefined)
    readonly property var wiredDevices: root.devices.filter(device => device?.type === DeviceType.Wired && device.nmManaged)

    readonly property var wifiDevice: root.wifiDevices[0] ?? null
    readonly property var wiredDevice: root.wiredDevices.find(device => device.connected) ?? root.wiredDevices[0] ?? null

    readonly property bool available: root.wifiDevice !== null || root.wiredDevice !== null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool online: Networking.connectivity === NetworkConnectivity.Full

    readonly property var networks: {
        const device = root.wifiDevice;
        if (!device)
            return [];

        const strongest = new Map();
        for (const network of device.networks?.values ?? []) {
            if (!network.name)
                continue;

            strongest.set(network.name, root.preferred(strongest.get(network.name), network));
        }

        return Array.from(strongest.values()).sort((first, second) => root.preferred(first, second) === first ? -1 : 1);
    }

    readonly property var activeNetwork: root.networks.find(network => network.connected) ?? null

    readonly property string glyph: {
        if (root.activeNetwork)
            return Glyphs.wifi(root.signalPercent(root.activeNetwork));
        if (root.wiredDevice?.connected)
            return Icons.ethernet;
        if (!root.wifiEnabled)
            return Icons.wifiDisabled;
        return Icons.wifiOff;
    }

    function preferred(first, second) {
        if (!first)
            return second;
        if (first.connected !== second.connected)
            return first.connected ? first : second;
        if (first.known !== second.known)
            return first.known ? first : second;
        return root.signalPercent(first) >= root.signalPercent(second) ? first : second;
    }

    function signalPercent(network): int {
        return Num.percent(network?.signalStrength ?? 0);
    }

    function secured(network): bool {
        const security = network?.security;
        return security !== undefined && security !== WifiSecurityType.Open && security !== WifiSecurityType.Owe;
    }

    function enterprise(network): bool {
        const security = network?.security;
        if (security === undefined)
            return false;

        return security === WifiSecurityType.Wpa2Eap || security === WifiSecurityType.WpaEap || security === WifiSecurityType.DynamicWep || security === WifiSecurityType.Leap || security === WifiSecurityType.Wpa3SuiteB192;
    }

    function failureText(reason: int): string {
        const control = Appearance.control;
        switch (reason) {
        case ConnectionFailReason.NoSecrets:
            return control.failureNoSecrets;
        case ConnectionFailReason.WifiAuthTimeout:
            return control.failureAuthTimeout;
        case ConnectionFailReason.WifiNetworkLost:
            return control.failureNetworkLost;
        case ConnectionFailReason.WifiClientDisconnected:
            return control.failureDisconnected;
        default:
            return control.failureGeneric;
        }
    }

    function connectTo(network): void {
        network?.connect();
    }

    function connectToWithPsk(network, psk: string): void {
        network?.connectWithPsk(psk);
    }

    function disconnectFrom(network): void {
        network?.disconnect();
    }

    function forgetNetwork(network): void {
        network?.forget();
    }

    function setWifiEnabled(enabled: bool): void {
        Networking.wifiEnabled = enabled;
    }

    Binding {
        when: root.wifiDevice !== null
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.scanning
    }
}
