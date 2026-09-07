pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property bool scanning: false
    property var details: ({})
    property var connecting: null
    property var stalled: null
    property var signals: ({})

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

    readonly property var activeDevice: {
        if (root.activeNetwork)
            return root.wifiDevice;
        return root.wiredDevice?.connected ? root.wiredDevice : null;
    }

    readonly property string activeInterface: root.activeDevice?.name ?? ""

    readonly property string mac: root.details[NetFields.mac] ?? ""
    readonly property string address: root.details[NetFields.address] ?? ""
    readonly property string gateway: root.details[NetFields.gateway] ?? ""
    readonly property string dns: root.details[NetFields.dns] ?? ""
    readonly property string profile: root.details[NetFields.connection] ?? ""

    readonly property string glyph: {
        if (root.activeNetwork)
            return Glyphs.wifi(root.signalPercent(root.activeNetwork));
        if (root.wiredDevice?.connected)
            return Icons.ethernet;
        if (!root.wifiEnabled)
            return Icons.wifiDisabled;
        return Icons.wifiOff;
    }

    function parseDetails(payload: string): var {
        const parsed = {};

        for (const line of payload.trim().split("\n")) {
            const split = line.indexOf(":");
            if (split < 0)
                continue;

            const key = line.slice(0, split).replace(/\[\d+\]$/, "");
            const value = line.slice(split + 1).trim();

            if (value === "" || value === "--" || parsed[key] !== undefined)
                continue;

            parsed[key] = value;
        }

        return parsed;
    }

    function parseSignals(payload: string): var {
        const parsed = {};
        let level = 0;

        for (const line of payload.split("\n")) {
            const trimmed = line.trim();

            if (trimmed.startsWith("BSS ")) {
                level = 0;
            } else if (trimmed.startsWith("signal:")) {
                level = Math.round(parseFloat(trimmed.slice("signal:".length)));
            } else if (trimmed.startsWith("SSID:")) {
                const name = trimmed.slice("SSID:".length).trim();

                if (name !== "" && level !== 0 && !isNaN(level) && (parsed[name] === undefined || level > parsed[name]))
                    parsed[name] = level;
            }
        }

        return parsed;
    }

    function rssi(network): int {
        return root.signals[network?.name ?? ""] ?? 0;
    }

    function signalText(network): string {
        const level = root.rssi(network);
        if (level !== 0)
            return Appearance.control.rssiTemplate.arg(level);

        return Appearance.scale.percentTemplate.arg(root.signalPercent(network));
    }

    function securityText(network): string {
        const security = network?.security;
        if (security === undefined || !root.secured(network))
            return Appearance.control.labelOpen;

        return WifiSecurityType.toString(security);
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

    function beginConnect(network): void {
        root.stalled = null;
        root.connecting = network;
        connectTimeout.restart();
    }

    function endConnect(): void {
        root.connecting = null;
        connectTimeout.stop();
    }

    function busy(network): bool {
        return (network?.stateChanging ?? false) && root.stalled !== network;
    }

    function failed(network): bool {
        return root.stalled === network;
    }

    function connectTo(network): void {
        root.beginConnect(network);
        network?.connect();
    }

    function connectToWithPsk(network, psk: string): void {
        root.beginConnect(network);
        network?.connectWithPsk(psk);
    }

    function disconnectFrom(network): void {
        root.endConnect();
        network?.disconnect();
    }

    function forgetNetwork(network): void {
        network?.forget();
    }

    function setWifiEnabled(enabled: bool): void {
        Networking.wifiEnabled = enabled;
    }

    signal connectStalled(var network)

    onActiveNetworkChanged: {
        if (root.activeNetwork)
            root.endConnect();
    }

    onActiveInterfaceChanged: {
        root.details = ({});
        if (root.activeInterface !== "")
            detailPoller.poll();
    }

    Timer {
        id: connectTimeout

        interval: Appearance.control.connectTimeout

        onTriggered: {
            const network = root.connecting;
            root.connecting = null;

            if (!network || network.connected)
                return;

            root.stalled = network;
            network.disconnect();
            root.connectStalled(network);
        }
    }

    Poller {
        command: ["sh", "-c", Commands.wifiSignals.arg(root.wifiDevice?.name ?? "")]
        interval: Appearance.control.rssiPollInterval
        polling: root.scanning && root.wifiDevice !== null

        onReceived: text => root.signals = root.parseSignals(text)
    }

    Poller {
        id: detailPoller

        command: ["sh", "-c", Commands.networkDetails.arg(NetFields.queried.join(",")).arg(root.activeInterface)]
        interval: Appearance.control.detailPollInterval
        polling: root.activeInterface !== ""

        onReceived: text => root.details = root.parseDetails(text)
    }

    Binding {
        when: root.wifiDevice !== null
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.scanning
    }
}
