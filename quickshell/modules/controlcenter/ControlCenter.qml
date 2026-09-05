import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums

Scope {
    id: root

    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-wifi"

        onPressed: ControlState.toggle(ControlSection.network)
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-audio"

        onPressed: ControlState.toggle(ControlSection.audio)
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-bluetooth"

        onPressed: ControlState.toggle(ControlSection.bluetooth)
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-toggle"

        onPressed: ControlState.togglePanel()
    }

    IpcHandler {
        target: "controlcenter"

        function open(section: string): string {
            ControlState.show(section === "" ? ControlSection.network : section);
            return ControlState.section;
        }

        function close(): string {
            ControlState.hide();
            return IpcStatus.closed;
        }

        function toggle(section: string): string {
            ControlState.toggle(section === "" ? ControlSection.network : section);
            return ControlState.opened ? ControlState.section : IpcStatus.closed;
        }

        function status(): string {
            return `opened=${ControlState.opened} section=${ControlState.section}`;
        }
    }
}
