pragma Singleton

import Quickshell
import qs.core.config

Singleton {
    id: root

    function clamp(value: real, low: real, high: real): real {
        return Math.max(low, Math.min(high, value));
    }

    function clamp01(value: real): real {
        return root.clamp(isNaN(value) ? 0 : value, 0, 1);
    }

    function wrap(index: int, delta: int, count: int): int {
        if (count <= 0)
            return 0;

        return ((index + delta) % count + count) % count;
    }

    function pushCapped(list: var, value: real, cap: int): var {
        const next = list.concat([value]);
        return next.length > cap ? next.slice(next.length - cap) : next;
    }

    function percent(raw: real): int {
        const value = raw ?? 0;
        return Math.round(value <= Appearance.scale.fraction ? value * Appearance.scale.percent : value);
    }

    function toPercent(raw: real): int {
        return root.clamp(Math.round(raw), 0, Appearance.scale.percent);
    }
}
