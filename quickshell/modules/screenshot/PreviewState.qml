pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.constants
import qs.core.helpers
import qs.services

Singleton {
    id: root

    property string path: ""
    property string screen: ""
    property bool shown: false
    property bool hovered: false

    function show(path: string): void {
        if (Lock.locked || !path)
            return;

        root.path = path;
        root.screen = Monitors.focused;
        root.shown = true;
        timer.restart();
    }

    function hide(): void {
        root.shown = false;
        root.hovered = false;
    }

    function edit(): void {
        root.hide();
        EditorState.open(root.path);
    }

    function pin(): void {
        root.hide();
        PinState.add(root.path);
    }

    function reveal(): void {
        root.hide();
        Quickshell.execDetached([...Commands.screenshotReveal, `array:string:file://${root.path}`, "string:"]);
    }

    function trash(): void {
        root.hide();
        Quickshell.execDetached([...Commands.screenshotTrash, root.path]);
    }

    Timer {
        id: timer

        interval: Appearance.preview.timeout
        running: root.shown && !root.hovered

        onTriggered: root.hide()
    }

    Connections {
        target: Lock

        function onLockedChanged(): void {
            if (Lock.locked)
                root.hide();
        }
    }
}
