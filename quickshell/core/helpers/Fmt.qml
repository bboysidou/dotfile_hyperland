pragma Singleton

import Quickshell
import qs.core.config
import qs.core.constants

Singleton {
    id: root

    function relativeTime(timestamp: real): string {
        const delta = Date.now() - timestamp;

        if (delta < Units.msPerMinute)
            return Appearance.notif.relativeNow;

        const minutes = Math.floor(delta / Units.msPerMinute);
        if (minutes < Units.minutesPerHour)
            return `${minutes}m`;

        const hours = Math.floor(minutes / Units.minutesPerHour);
        if (hours < Units.hoursPerDay)
            return `${hours}h`;

        return `${Math.floor(delta / Units.msPerDay)}d`;
    }

    function duration(seconds: real): string {
        if (!isFinite(seconds) || seconds <= 0)
            return "0:00";

        const total = Math.floor(seconds);
        const hours = Math.floor(total / Units.secondsPerHour);
        const minutes = Math.floor(total % Units.secondsPerHour / Units.secondsPerMinute);
        const secs = total % Units.secondsPerMinute;

        if (hours > 0)
            return `${hours}:${String(minutes).padStart(2, "0")}:${String(secs).padStart(2, "0")}`;

        return `${minutes}:${String(secs).padStart(2, "0")}`;
    }

    function uptime(seconds: real): string {
        if (!isFinite(seconds) || seconds <= 0)
            return Appearance.power.uptimeUnknown;

        const total = Math.floor(seconds);
        const days = Math.floor(total / Units.secondsPerDay);
        const hours = Math.floor(total % Units.secondsPerDay / Units.secondsPerHour);
        const minutes = Math.floor(total % Units.secondsPerHour / Units.secondsPerMinute);

        if (days > 0)
            return `${days}d ${hours}h`;
        if (hours > 0)
            return `${hours}h ${minutes}m`;

        return `${minutes}m`;
    }

    function gb(bytes: real): string {
        return root.gbValue(bytes / Units.bytesPerGb);
    }

    function gbFromKb(kilobytes: real): string {
        return root.gbValue(kilobytes / Units.kbPerGb);
    }

    function gbValue(value: real): string {
        return `${value >= 100 ? value.toFixed(0) : value.toFixed(1)}GB`;
    }

    function rate(bytesPerSecond: real): string {
        const units = ["B/s", "KB/s", "MB/s", "GB/s"];
        let value = Math.max(0, bytesPerSecond);
        let unit = 0;

        while (value >= Units.bytesPerKb && unit < units.length - 1) {
            value /= Units.bytesPerKb;
            unit++;
        }

        return `${value.toFixed(unit === 0 ? 0 : 1)} ${units[unit]}`;
    }

    function age(fromMs: real, now: date): string {
        const minutes = Math.floor((now.getTime() - fromMs) / Units.msPerMinute);

        if (minutes < 60)
            return `${Math.max(minutes, 1)}m ago`;

        const hours = Math.floor(minutes / 60);

        if (hours < 24)
            return `${hours}h ago`;

        return `${Math.floor(hours / 24)}d ago`;
    }

    function markup(source: string): string {
        const escaped = source.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        const restored = escaped.replace(/&lt;(\/?)(b|i|u)&gt;/g, "<$1$2>").replace(/&lt;br\s*\/?&gt;/g, "<br>");

        return restored.replace(/\n/g, "<br>");
    }

    function icon(name: string): string {
        if (!name)
            return "";

        if (name.startsWith("file://"))
            return name;

        if (name.startsWith("/"))
            return `file://${name}`;

        return Quickshell.iconPath(name, true);
    }

    function domain(text: string): string {
        const match = /https?:\/\/([^\s\/]+)/.exec(text);

        if (!match)
            return "";

        const host = match[1].toLowerCase().replace(/:\d+$/, "");

        return host.length <= 253 && /^[a-z0-9.-]+$/.test(host) ? host : "";
    }
}
