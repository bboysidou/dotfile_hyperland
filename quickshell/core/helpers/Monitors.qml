pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string focused: Hyprland.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? ""

    function covered(screen): bool {
        return Hyprland.monitorFor(screen)?.activeWorkspace?.toplevels.values.some(t => t.wayland?.fullscreen ?? false) ?? false;
    }
}
