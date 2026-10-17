pragma Singleton

import QtQuick
import Quickshell
import qs.core.config

Singleton {
    id: root

    function level(value: real, warning: real, critical: real, base: color): color {
        if (value >= critical)
            return Colours.critical;
        if (value >= warning)
            return Colours.warning;
        return base;
    }

    function usage(percent: real, base: color): color {
        return root.level(percent, Appearance.bar.usageWarning, Appearance.bar.usageCritical, base);
    }
}
