pragma Singleton

import Quickshell
import qs.core.enums

Singleton {
    id: root

    property bool opened: false
    property string section: ControlSection.network

    function show(target: string): void {
        root.section = target;
        root.opened = true;
    }

    function hide(): void {
        root.opened = false;
    }

    function togglePanel(): void {
        root.opened = !root.opened;
    }

    function toggle(target: string): void {
        if (root.opened && root.section === target)
            root.hide();
        else
            root.show(target);
    }
}
