pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string focused: Hyprland.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? ""
}
