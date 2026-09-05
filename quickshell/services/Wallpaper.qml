pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.wallpaper.stateFile}`
    readonly property string imageDir: `${Paths.home}/${Appearance.wallpaper.dir}`
    readonly property string seedPath: `${Paths.home}/${Appearance.wallpaper.hyprpaperConf}`

    property bool ready: false
    property bool seeded: false
    property string current: ""
    property string committed: ""
    property var paths: []

    function set(path: string): void {
        if (!path || path === root.committed)
            return;

        root.committed = path;
        root.current = path;
        state.setText(path);
    }

    function preview(path: string): void {
        if (path)
            root.current = path;
    }

    function stopPreview(): void {
        root.current = root.committed;
    }

    function name(path: string): string {
        return Paths.basename(path);
    }

    function query(search: string): var {
        if (!search)
            return root.paths;

        return root.paths.filter(path => Str.contains(root.name(path), search));
    }

    function isImage(path: string): bool {
        return Appearance.wallpaper.extensions.includes(Paths.extension(path));
    }

    function apply(payload: string): void {
        root.paths = payload.trim().split("\n").map(line => line.trim()).filter(line => line.length > 0 && root.isImage(line)).sort();
    }

    function seed(): void {
        root.seeded = true;

        const match = seedSource.text().match(new RegExp(Appearance.wallpaper.seedPattern, "m"));

        if (match)
            root.set(match[1].trim());
        else if (root.paths.length > 0)
            root.set(root.paths[0]);
    }

    function refresh(): void {
        scan.running = true;
    }

    Process {
        id: prepare

        command: ["mkdir", "-p", root.stateDir]
        running: true

        onExited: root.ready = true
    }

    Process {
        id: scan

        command: ["find", root.imageDir, "-maxdepth", "1", "-type", "f"]

        stdout: StdioCollector {
            onStreamFinished: root.apply(text)
        }
    }

    FileView {
        id: state

        path: root.ready ? root.statePath : ""
        atomicWrites: true
        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            const value = text().trim();

            if (value) {
                root.committed = value;
                root.current = value;
            }
        }

        onLoadFailed: {
            if (!root.seeded)
                root.seed();
        }
    }

    FileView {
        id: seedSource

        path: root.seedPath
        blockLoading: true
    }

    Component.onCompleted: root.refresh()
}
