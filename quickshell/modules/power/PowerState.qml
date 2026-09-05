pragma Singleton

import Quickshell
import Quickshell.Hyprland
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.border
import qs.services

Singleton {
    id: root

    property bool opened: false
    property int index: root.defaultIndex
    property string screen: ""

    readonly property var actions: [
        {
            action: PowerAction.lock,
            icon: Icons.lockScreen,
            label: Appearance.power.lockLabel,
            shortcut: Appearance.power.lockKey
        },
        {
            action: PowerAction.logout,
            icon: Icons.logout,
            label: Appearance.power.logoutLabel,
            shortcut: Appearance.power.logoutKey
        },
        {
            action: PowerAction.reboot,
            icon: Icons.restart,
            label: Appearance.power.rebootLabel,
            shortcut: Appearance.power.rebootKey
        },
        {
            action: PowerAction.shutdown,
            icon: Icons.power,
            label: Appearance.power.shutdownLabel,
            shortcut: Appearance.power.shutdownKey
        }
    ]

    readonly property int defaultIndex: root.actions.findIndex(entry => entry.action === PowerAction.shutdown)
    readonly property var current: root.actions[root.index] ?? null

    function show(): void {
        BorderState.closeAll();
        Uptime.refresh();
        root.screen = Monitors.focused;
        root.index = root.defaultIndex;
        root.opened = true;
    }

    function hide(): void {
        root.opened = false;
    }

    function toggle(): void {
        if (root.opened)
            root.hide();
        else
            root.show();
    }

    function step(delta: int): void {
        if (!delta)
            return;

        const count = root.actions.length;
        root.index = (root.index + delta + count) % count;
    }

    function select(index: int): void {
        if (index >= 0 && index < root.actions.length)
            root.index = index;
    }

    function activate(): void {
        if (root.current)
            root.run(root.current.action);
    }

    function activateKey(text: string): bool {
        if (!text)
            return false;

        const index = root.indexForKey(text);
        if (index === -1)
            return false;

        root.select(index);
        root.activate();
        return true;
    }

    function indexForKey(text: string): int {
        const digit = Number(text);
        if (Number.isInteger(digit) && digit >= 1 && digit <= root.actions.length)
            return digit - 1;

        const key = text.toLowerCase();
        return root.actions.findIndex(entry => entry.shortcut === key);
    }

    function run(action: string): void {
        root.hide();

        if (action === PowerAction.lock)
            Lock.show();
        else if (action === PowerAction.logout)
            Hyprland.dispatch("exit");
        else if (action === PowerAction.reboot)
            Quickshell.execDetached(Commands.reboot);
        else if (action === PowerAction.shutdown)
            Quickshell.execDetached(Commands.shutdown);
    }
}
