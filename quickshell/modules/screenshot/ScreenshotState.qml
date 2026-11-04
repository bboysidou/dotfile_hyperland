pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string mode: ScreenshotMode.smart
    property var parts: []
    property string shape: ScreenshotShape.free
    property var clients: null
    property var cursor: null
    property var lastRegion: null
    property int serial: 0
    property bool annotate: false
    property bool reading: false

    readonly property bool listed: root.clients !== null
    readonly property string dir: `${Paths.home}/${Appearance.shot.dir}`

    function open(mode: string): void {
        if (Lock.locked || root.opened)
            return;

        PreviewState.hide();
        root.mode = mode;
        root.annotate = false;
        root.reading = false;
        root.parts = [];
        root.clients = null;
        root.cursor = null;
        clientsProc.running = true;
        cursorProc.running = true;
        root.opened = true;
        watchdog.restart();
    }

    function read(): void {
        root.open(ScreenshotMode.smart);
        root.reading = root.opened;
    }

    function close(): void {
        watchdog.stop();
        root.opened = false;
        root.parts = [];
    }

    function toggle(): void {
        if (root.opened)
            root.close();
        else
            root.open(ScreenshotMode.smart);
    }

    function settle(): void {
        watchdog.stop();
    }

    function fail(reason: string): void {
        root.close();
        Quickshell.execDetached([...Commands.screenshotFailed, Appearance.screenshot.failTitle, reason]);
    }

    function cycleShape(delta: int): void {
        const values = ScreenshotShape.values;
        const index = values.indexOf(root.shape);
        root.shape = values[(index + delta + values.length) % values.length];
    }

    function pixelSize(frame, screen): var {
        const source = frame.sourceSize;
        const swapped = (source.width > source.height) !== (screen.width > screen.height);
        return {
            width: swapped ? source.height : source.width,
            height: swapped ? source.width : source.height
        };
    }

    function windowsFor(screen): var {
        const workspace = Hyprland.monitorFor(screen)?.activeWorkspace?.id ?? -1;
        return (root.clients ?? []).filter(c => c.mapped && !c.hidden && c.workspace?.id === workspace).sort((a, b) => (b.floating - a.floating) || (a.focusHistoryID - b.focusHistoryID)).map(c => Geom.clamp(Geom.rect(c.at[0] - screen.x, c.at[1] - screen.y, c.size[0], c.size[1]), screen.width, screen.height)).filter(r => r.width > 0 && r.height > 0);
    }

    function base(): string {
        return Qt.formatDateTime(new Date(), Appearance.screenshot.filePattern);
    }

    function grab(frame, screen, done): void {
        root.serial += 1;
        const temp = `${Paths.runtime}/${Appearance.screenshot.frameFile.arg(screen.name).arg(String(Date.now())).arg(String(root.serial))}`;
        const started = frame.grabToImage(result => {
            if (!result.saveToFile(temp))
                root.fail(Appearance.screenshot.failSave);
            else
                done(temp);
        });

        if (!started)
            root.fail(Appearance.screenshot.failGrab);
    }

    function launch(command, label: string): void {
        output.createObject(root, {
            label: label,
            edit: root.annotate,
            command: command
        });
    }

    function capture(frame, screen, region, label: string): void {
        const base = root.base();
        root.lastRegion = {
            screen: screen.name,
            rect: region
        };
        const geometry = [region.x, region.y, region.width, region.height, screen.width, screen.height].map(String);
        root.grab(frame, screen, temp => {
            root.close();
            if (root.reading)
                EditorOutput.extract(temp, geometry);
            else
                root.launch(["bash", "-c", Commands.screenshotOutput, "bash", temp, root.dir, base, String(Appearance.screenshot.maxSuffix), ...geometry], label);
        });
    }

    function contribute(frame, screen): void {
        root.grab(frame, screen, temp => {
            if (!root.opened) {
                Quickshell.execDetached([...Commands.screenshotDiscard, temp]);
                return;
            }

            root.parts = [...root.parts, {
                    temp: temp,
                    x: screen.x,
                    y: screen.y,
                    width: screen.width,
                    height: screen.height
                }];
            if (root.parts.length === Quickshell.screens.length)
                root.merge();
        });
    }

    function merge(): void {
        const parts = root.parts;
        const left = Math.min(...parts.map(p => p.x));
        const top = Math.min(...parts.map(p => p.y));
        const right = Math.max(...parts.map(p => p.x + p.width));
        const bottom = Math.max(...parts.map(p => p.y + p.height));
        const specs = parts.reduce((list, p) => list.concat([p.temp, p.x - left, p.y - top, p.width, p.height].map(String)), []);
        root.close();
        root.launch(["bash", "-c", Commands.screenshotMerge, "bash", root.dir, root.base(), String(Appearance.screenshot.maxSuffix), String(right - left), String(bottom - top), ...specs], Appearance.shot.fullscreenLabel);
    }

    function announce(path: string, label: string): void {
        if (Appearance.preview.enabled)
            PreviewState.show(path);
        else
            root.notify(path, label);
    }

    function notify(path: string, label: string): void {
        Quickshell.execDetached(["sh", "-c", Commands.shotNotify.arg(path).arg(Appearance.shot.notifyTitle).arg(`${label}\n${Paths.basename(path)}`).arg(Appearance.shot.showInFolderLabel).arg(Appearance.notif.previewCategory).arg(Appearance.editor.editAction)]);
    }

    Connections {
        target: Lock

        function onLockedChanged(): void {
            if (Lock.locked)
                root.close();
        }
    }

    Timer {
        id: watchdog

        interval: Appearance.screenshot.captureTimeout

        onTriggered: root.fail(Appearance.screenshot.failTimeout)
    }

    Process {
        id: clientsProc

        command: Commands.screenshotClients

        stdout: StdioCollector {
            onStreamFinished: root.clients = JSON.parse(text || "[]")
        }

        onExited: code => {
            if (code !== 0)
                root.clients = [];
        }
    }

    Process {
        id: cursorProc

        command: Commands.screenshotCursor

        stdout: StdioCollector {
            onStreamFinished: root.cursor = JSON.parse(text || "null")
        }
    }

    Component {
        id: output

        Process {
            id: proc

            property string label: ""
            property bool edit: false

            running: true

            stdout: StdioCollector {
                id: path
            }

            onExited: code => {
                if (code === 0 && path.text && proc.edit)
                    EditorState.open(path.text);
                else if (code === 0 && path.text)
                    root.announce(path.text, proc.label);
                else
                    root.fail(Appearance.screenshot.failOutput);
                proc.destroy();
            }
        }
    }
}
