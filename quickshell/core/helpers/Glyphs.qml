pragma Singleton

import Quickshell
import qs.core.config

Singleton {
    id: root

    function volume(percent: int, muted: bool): string {
        if (muted)
            return Icons.volumeMuted;
        if (percent >= Appearance.audio.highFloor)
            return Icons.volumeHigh;
        if (percent >= Appearance.audio.mediumFloor)
            return Icons.volumeMedium;
        if (percent > 0)
            return Icons.volumeLow;

        return Icons.volumeOff;
    }

    function wifi(percent: int): string {
        const control = Appearance.control;
        const levels = Icons.wifiLevels;

        if (percent >= control.wifiSignalHigh)
            return levels[4];
        if (percent >= control.wifiSignalMedium)
            return levels[3];
        if (percent >= control.wifiSignalLow)
            return levels[2];
        if (percent > 0)
            return levels[1];

        return levels[0];
    }

    function mouse(charging: bool): string {
        return charging ? Icons.mouseCharging : Icons.mouse;
    }

    function playback(playing: bool): string {
        return playing ? Icons.pause : Icons.play;
    }

    function btDevice(icon: string): string {
        return Icons.bluetoothDeviceGlyphs[icon] ?? Icons.unknownDevice;
    }

    function bluetooth(enabled: bool, connected: int): string {
        if (!enabled)
            return Icons.bluetoothDisabled;

        return connected > 0 ? Icons.bluetoothConnected : Icons.bluetooth;
    }

    function batteryRamp(percent: int, charging: bool): string {
        const ramp = charging ? Icons.mouseCharge : Icons.mouseLevels;
        const last = ramp.length - 1;

        return ramp[Num.clamp(Math.round(percent / Appearance.scale.percent * last), 0, last)];
    }
}
