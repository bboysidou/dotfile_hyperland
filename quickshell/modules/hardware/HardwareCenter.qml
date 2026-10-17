import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.modules.controlcenter
import qs.modules.updates
import qs.services

Scope {
    id: root

    Binding {
        target: CpuStats
        property: "active"
        value: HardwareState.opened && HardwareState.section === HardwareSection.cpu
    }

    Binding {
        target: GpuStats
        property: "active"
        value: HardwareState.opened && HardwareState.section === HardwareSection.gpu
    }

    Binding {
        target: Dimms
        property: "active"
        value: HardwareState.opened && HardwareState.section === HardwareSection.memory
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "hardware"

        onPressed: HardwareState.toggle(HardwareState.section)
    }

    IpcHandler {
        target: "hardware"

        function open(section: string): string {
            HardwareState.show(section === "" ? HardwareSection.cpu : section);
            return HardwareState.section;
        }

        function close(): string {
            HardwareState.hide();
            return IpcStatus.closed;
        }

        function toggle(section: string): string {
            HardwareState.toggle(section === "" ? HardwareState.section : section);
            return HardwareState.opened ? HardwareState.section : IpcStatus.closed;
        }

        function status(): string {
            return `opened=${HardwareState.opened} section=${HardwareState.section}`;
        }
    }

    Connections {
        target: HardwareState

        function onOpenedChanged(): void {
            if (!HardwareState.opened)
                return;

            ControlState.hide();
            UpdatesState.hide();
        }
    }

    Connections {
        target: ControlState

        function onOpenedChanged(): void {
            if (ControlState.opened)
                HardwareState.hide();
        }
    }

    Connections {
        target: UpdatesState

        function onOpenedChanged(): void {
            if (UpdatesState.opened)
                HardwareState.hide();
        }
    }
}
