pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.UPower
import qs.core.config
import qs.core.constants
import qs.core.enums

Singleton {
    id: root

    property bool enabled: false
    property bool automatic: false
    property bool dismissed: false
    property bool decorating: false
    property int restoreProfile: PowerProfile.Balanced
    property int restoreBrightness: -1

    readonly property var config: Appearance.lowPower
    readonly property bool low: Battery.discharging && Battery.percent > 0 && Battery.percent <= root.config.autoPercent

    function sync(): void {
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            root.setEnabled(true);
    }

    function toggle(): void {
        root.setEnabled(!root.enabled);
    }

    function setEnabled(on: bool): void {
        if (on === root.enabled)
            return;

        root.enabled = on;
        if (on)
            root.engage();
        else
            root.release();
    }

    function engage(): void {
        if (PowerProfiles.profile !== PowerProfile.PowerSaver) {
            root.restoreProfile = PowerProfiles.profile;
            PowerProfiles.profile = PowerProfile.PowerSaver;
        }
        root.dim();
        root.decorate();
    }

    function release(): void {
        if (root.automatic && !Battery.charging)
            root.dismissed = true;
        root.automatic = false;
        root.decorating = false;

        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            PowerProfiles.profile = root.restoreProfile;
        root.undim();
        reloader.running = true;
    }

    function dim(): void {
        root.restoreBrightness = -1;
        if (Brightness.backend !== BrightnessBackend.backlight || Brightness.percent <= root.config.brightnessCap)
            return;

        root.restoreBrightness = Brightness.percent;
        Brightness.setPercent(root.config.brightnessCap);
    }

    function undim(): void {
        if (root.restoreBrightness >= 0 && Brightness.percent === root.config.brightnessCap)
            Brightness.setPercent(root.restoreBrightness);
        root.restoreBrightness = -1;
    }

    function decorate(): void {
        root.decorating = true;
        Displays.refresh();
    }

    function internal(name: string): bool {
        return root.config.internalPrefixes.some(prefix => name.startsWith(prefix));
    }

    function slowed(monitor): string {
        const settings = monitor.settings;
        const group = monitor.modes.find(entry => entry.width === settings.width && entry.height === settings.height);
        const rate = (group?.rates ?? []).find(value => Number(value) >= root.config.minRefreshRate);

        if (!rate || Number(rate) >= Number(settings.rate))
            return "";
        return Displays.line(monitor.name, Object.assign({}, settings, {
            rate: rate
        }));
    }

    function script(): string {
        const panels = Displays.monitors.filter(monitor => !monitor.settings.disabled && root.internal(monitor.name));
        return [root.config.hyprScript].concat(panels.map(monitor => root.slowed(monitor)).filter(line => line !== "")).join("\n");
    }

    onLowChanged: {
        if (root.low && !root.enabled && !root.dismissed) {
            root.automatic = true;
            root.setEnabled(true);
        }
    }

    Connections {
        target: PowerProfiles

        function onProfileChanged(): void {
            if (PowerProfiles.profile !== PowerProfile.PowerSaver)
                root.restoreProfile = PowerProfiles.profile;
            root.setEnabled(PowerProfiles.profile === PowerProfile.PowerSaver);
        }
    }

    Connections {
        target: Battery

        function onChargingChanged(): void {
            if (!Battery.charging)
                return;

            root.dismissed = false;
            if (root.automatic)
                root.setEnabled(false);
        }
    }

    Connections {
        target: Displays

        function onMonitorsChanged(): void {
            if (!root.decorating || Displays.confirming)
                return;

            root.decorating = false;
            evaluator.command = Commands.hyprEval.concat([root.script()]);
            evaluator.running = true;
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (event.name === root.config.reloadEvent && root.enabled && !reloader.running)
                root.decorate();
        }
    }

    Process {
        id: evaluator
    }

    Process {
        id: reloader

        command: Commands.hyprReload
    }
}
