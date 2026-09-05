import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.services

Scope {
    id: root

    readonly property bool onDash: DashState.tab === DashSection.dash
    readonly property bool onPerf: DashState.tab === DashSection.performance
    readonly property bool onMedia: DashState.tab === DashSection.media

    Binding {
        target: SysInfo
        property: "detailed"
        value: DashState.opened && root.onPerf
    }

    Binding {
        target: Cava
        property: "active"
        value: DashState.opened && Players.playing && (root.onMedia || root.onDash)
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "dashboard"

        onPressed: DashState.toggle("")
    }

    IpcHandler {
        target: "dashboard"

        function open(section: string): string {
            DashState.show(section);
            return DashState.tab;
        }

        function close(): string {
            DashState.hide();
            return IpcStatus.closed;
        }

        function toggle(section: string): string {
            DashState.toggle(section);
            return DashState.pinned ? DashState.tab : IpcStatus.closed;
        }

        function next(): string {
            DashState.step(1);
            return DashState.tab;
        }

        function previous(): string {
            DashState.step(-1);
            return DashState.tab;
        }

        function status(): string {
            return `opened=${DashState.opened} pinned=${DashState.pinned} hovering=${DashState.hovering} tab=${DashState.tab}`;
        }
    }
}
