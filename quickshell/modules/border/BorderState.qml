pragma Singleton

import QtQuick
import Quickshell
import qs.core.enums
import qs.modules.barlayout
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.display
import qs.modules.fingerprint
import qs.modules.hardware
import qs.modules.launcher
import qs.modules.screenshot
import qs.modules.settings
import qs.modules.share
import qs.modules.updates

Singleton {
    id: root

    readonly property var states: [LauncherState, ShotState, ShareState, ControlState, UpdatesState, HardwareState, DashState, DisplayState, SettingsState, FingerprintState, BarLayoutState]
    readonly property bool sideOpen: LauncherState.opened || ControlState.opened || UpdatesState.opened || HardwareState.opened || ShotState.opened || ShareState.opened || DisplayState.opened || SettingsState.opened || FingerprintState.opened || FingerprintState.enrollOpened || BarLayoutState.opened
    readonly property bool panelOpen: root.sideOpen || DashState.pinned
    readonly property bool transientOpen: root.states.some(state => state !== root.pinnedState && root.isOpen(state))
    readonly property bool pinnedOpen: root.pinnedState !== null && root.isOpen(root.pinnedState)
    readonly property bool pinned: root.pinnedState !== null

    property real rightInset: 0
    property QtObject pinnedState: null
    property string pinnedScreen: ""

    function isOpen(state: QtObject): bool {
        if (state === FingerprintState)
            return FingerprintState.opened || FingerprintState.enrollOpened;
        if (state === DashState)
            return DashState.pinned;
        return state.opened;
    }

    function edgeOf(state: QtObject): string {
        if (state === LauncherState || state === ShotState || state === ShareState)
            return BarEdge.bottom;
        if (state === FingerprintState && FingerprintState.enrollOpened)
            return BarEdge.bottom;
        if (state === DisplayState || state === BarLayoutState || state === DashState)
            return BarEdge.top;
        return BarEdge.right;
    }

    function close(state: QtObject): void {
        if (state === ShareState)
            ShareState.dismiss();
        else if (root.isOpen(state))
            state.hide();
    }

    function closeUnpinned(state: QtObject): void {
        if (state !== root.pinnedState)
            root.close(state);
    }

    function togglePin(screenName: string, state: QtObject): void {
        if (root.pinnedState === state) {
            root.unpin();
            return;
        }

        if (state === DashState && !DashState.pinned)
            DashState.show("");

        root.pinnedScreen = screenName;
        root.pinnedState = state;
    }

    function unpin(): void {
        root.pinnedState = null;
    }

    onPinnedOpenChanged: {
        if (!root.pinnedOpen)
            root.unpin();
    }

    function closeExcept(keep: QtObject): void {
        for (const state of root.states) {
            if (state === keep)
                continue;
            if (keep !== null && state === root.pinnedState && root.edgeOf(state) !== root.edgeOf(keep))
                continue;
            root.close(state);
        }
    }

    function closeAll(): void {
        root.closeExcept(null);
    }

    function closeTransient(): void {
        for (const state of root.states)
            root.closeUnpinned(state);
    }

    Binding {
        target: DashState
        property: "blocked"
        value: root.states.some(state => state !== DashState && state !== root.pinnedState && root.isOpen(state)) || (root.pinnedState !== null && root.pinnedState !== DashState && root.edgeOf(root.pinnedState) === BarEdge.top)
    }

    Connections {
        target: LauncherState

        function onOpenedChanged(): void {
            if (LauncherState.opened)
                root.closeExcept(LauncherState);
        }
    }

    Connections {
        target: ShotState

        function onOpenedChanged(): void {
            if (ShotState.opened)
                root.closeExcept(ShotState);
        }
    }

    Connections {
        target: ShareState

        function onOpenedChanged(): void {
            if (ShareState.opened)
                root.closeExcept(ShareState);
        }
    }

    Connections {
        target: ControlState

        function onOpenedChanged(): void {
            if (ControlState.opened)
                root.closeExcept(ControlState);
        }

        function onSectionChanged(): void {
            if (root.pinnedState === ControlState)
                root.unpin();
        }
    }

    Connections {
        target: UpdatesState

        function onOpenedChanged(): void {
            if (UpdatesState.opened)
                root.closeExcept(UpdatesState);
        }
    }

    Connections {
        target: HardwareState

        function onOpenedChanged(): void {
            if (HardwareState.opened)
                root.closeExcept(HardwareState);
        }
    }

    Connections {
        target: DashState

        function onPinnedChanged(): void {
            if (DashState.pinned)
                root.closeExcept(DashState);
        }
    }

    Connections {
        target: DisplayState

        function onOpenedChanged(): void {
            if (DisplayState.opened)
                root.closeExcept(DisplayState);
        }
    }

    Connections {
        target: FingerprintState

        function onOpenedChanged(): void {
            if (FingerprintState.opened)
                root.closeExcept(FingerprintState);
        }

        function onEnrollOpenedChanged(): void {
            if (FingerprintState.enrollOpened)
                root.closeExcept(FingerprintState);
        }
    }

    Connections {
        target: BarLayoutState

        function onOpenedChanged(): void {
            if (BarLayoutState.opened)
                root.closeExcept(BarLayoutState);
        }
    }

    Connections {
        target: SettingsState

        function onOpenedChanged(): void {
            if (SettingsState.opened)
                root.closeExcept(SettingsState);
        }
    }
}
