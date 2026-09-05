pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property UPowerDevice device: {
        const devices = UPower.devices?.values ?? [];
        return devices.find(candidate => candidate.isLaptopBattery && candidate.isPresent) ?? null;
    }

    readonly property bool available: root.device !== null
    readonly property int percent: Math.round(root.device?.percentage ?? 0)
    readonly property bool charging: root.device?.state === UPowerDeviceState.Charging || root.device?.state === UPowerDeviceState.FullyCharged
}
