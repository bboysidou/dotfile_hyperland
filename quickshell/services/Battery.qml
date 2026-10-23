pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property var info: ({})

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

    readonly property string sysfs: {
        const path = root.device?.nativePath ?? "";
        if (!path)
            return "";
        return path.startsWith("/") ? path : `${Paths.powerSupply}/${path}`;
    }

    readonly property real rate: Math.abs(root.device?.changeRate ?? 0)
    readonly property real energy: root.device?.energy ?? 0
    readonly property real capacity: root.device?.energyCapacity ?? 0
    readonly property real design: {
        const energyDesign = root.micro(root.info.energy_full_design);
        if (energyDesign > 0)
            return energyDesign;
        return root.micro(root.info.charge_full_design) * root.micro(root.info.voltage_min_design);
    }
    readonly property real health: {
        if (root.device?.healthSupported)
            return root.device.healthPercentage;
        return root.design > 0 ? root.capacity / root.design * Appearance.scale.percent : 0;
    }
    readonly property real runtime: root.discharging && root.rate > 0 ? root.capacity / root.rate * Units.secondsPerHour : 0
    readonly property int cycles: Number(root.info.cycle_count ?? 0)
    readonly property real voltage: root.micro(root.info.voltage_now)
    readonly property real temperature: root.info.temp !== undefined ? Number(root.info.temp) / Units.tenthsPerUnit : NaN
    readonly property int limit: Number(root.info.charge_control_end_threshold ?? 0)
    readonly property int startLimit: Number(root.info.charge_control_start_threshold ?? 0)
    readonly property string cell: [root.info.technology, root.info.manufacturer, root.info.model_name || root.device?.model].filter(part => part && part !== "Unknown").join(" ")
    readonly property string serial: root.known(root.info.serial_number)
    readonly property string condition: root.known(root.info.health)
    readonly property int vendorHealth: Number(root.info.state_of_health ?? 0)
    readonly property int errorMargin: Number(root.info.capacity_error_margin ?? 0)
    readonly property real resistance: Number(root.info.internal_resistance ?? 0) / Units.microPerMilli
    readonly property real current: Math.abs(root.micro(root.info.current_now))
    readonly property var behaviour: Str.choices(root.info.charge_behaviour ?? "")
    readonly property var chargeTypes: Str.choices(root.info.charge_types ?? "")
    readonly property int madeYear: Number(root.info.manufacture_year ?? 0)
    readonly property int madeMonth: Number(root.info.manufacture_month ?? 0)
    readonly property int ageMonths: {
        if (root.madeYear <= 0)
            return -1;
        const now = new Date();
        return Math.max(0, (now.getFullYear() - root.madeYear) * Units.monthsPerYear + now.getMonth() + 1 - Math.max(1, root.madeMonth));
    }
    readonly property string upowerPath: root.sysfs ? Commands.upowerBatteryPath.arg(Paths.basename(root.sysfs)) : ""

    function micro(raw): real {
        const value = Number(raw ?? 0);
        return isFinite(value) ? value / Units.microPerUnit : 0;
    }

    function known(raw): string {
        const value = String(raw ?? "").trim();
        return value === "Unknown" ? "" : value;
    }

    function writable(attribute: string): bool {
        return root.info[`w:${attribute}`] === "1";
    }

    function refresh(): void {
        poller.poll();
    }

    function adopt(text: string): void {
        const parsed = {};
        for (const line of text.split("\n")) {
            const tab = line.indexOf("\t");
            if (tab > 0)
                parsed[line.slice(0, tab)] = line.slice(tab + 1).trim();
        }
        root.info = parsed;
    }

    Poller {
        id: poller

        command: ["sh", "-c", Commands.batteryInfo, "sh", root.sysfs]
        interval: Appearance.powerPanel.batteryInfoInterval
        polling: root.sysfs !== ""

        onReceived: text => root.adopt(text)
    }
}
