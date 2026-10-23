import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.services

Scope {
    id: root

    readonly property bool batteryShown: ControlState.opened && ControlState.section === ControlSection.power && ControlState.powerSection === PowerSection.battery && Battery.available

    Binding {
        target: BatteryHistory
        property: "active"
        value: root.batteryShown
    }

    Binding {
        target: Charger
        property: "active"
        value: root.batteryShown
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-network"

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
        name: "controlcenter-notifications"

        onPressed: ControlState.toggle(ControlSection.notifications)
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-power"

        onPressed: ControlState.toggle(ControlSection.power)
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
