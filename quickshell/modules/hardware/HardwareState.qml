pragma Singleton

import Quickshell
import qs.core.enums
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string section: HardwareSection.cpu

    function show(target: string): void {
        root.section = target;
        root.opened = true;
    }

    function hide(): void {
        root.opened = false;
    }

    function rescan(): void {
        GpuStats.rescan();
        SysInfo.rescan();
        Dimms.reload();
        CpuStats.reloadPower();
    }

    function toggle(target: string): void {
        if (root.opened && root.section === target)
            root.hide();
        else
            root.show(target);
    }
}
