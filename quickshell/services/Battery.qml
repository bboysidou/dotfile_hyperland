pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    readonly property UPowerDevice device: {
        const devices = UPower.devices?.values ?? [];
        return devices.find(candidate => candidate.isLaptopBattery && candidate.isPresent) ?? null;
    }

    readonly property bool available: root.device !== null
    readonly property int percent: Num.toPercent((root.device?.percentage ?? 0) * Appearance.scale.percent)
    readonly property int state: root.device?.state ?? UPowerDeviceState.Unknown
    readonly property bool charging: root.state === UPowerDeviceState.Charging || root.state === UPowerDeviceState.FullyCharged
    readonly property bool full: root.state === UPowerDeviceState.FullyCharged
    readonly property bool discharging: root.state === UPowerDeviceState.Discharging || root.state === UPowerDeviceState.PendingDischarge
    readonly property bool onAc: !UPower.onBattery
    readonly property real secondsLeft: {
        if (root.state === UPowerDeviceState.Charging)
            return root.device?.timeToFull ?? 0;
        if (root.discharging)
            return root.device?.timeToEmpty ?? 0;
        return 0;
    }
}
