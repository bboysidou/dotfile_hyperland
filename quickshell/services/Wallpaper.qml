pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.enums
import qs.core.helpers

Singleton {
    id: root

    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.wallpaper.stateFile}`
    readonly property string fitPath: `${root.stateDir}/${Appearance.wallpaper.fitStateFile}`
    readonly property string imageDir: `${Paths.home}/${Appearance.wallpaper.dir}`

    property bool ready: false
    property bool missing: false
    property string current: ""
    property string committed: ""
    property var paths: []
    property var fits: ({})
    property bool fitsLoaded: false

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

    function fitFor(path: string): string {
        return root.fits[path] ?? WallpaperFit.fill;
    }

    function fillModeFor(path: string): int {
        return WallpaperFit.fillModes[root.fitFor(path)];
    }

    function isUnscaled(path: string): bool {
        return WallpaperFit.unscaled.includes(root.fitFor(path));
    }

    function spans(path: string): bool {
        return root.fitFor(path) === WallpaperFit.span;
    }

    function desktop(): var {
        const screens = Quickshell.screens;
        if (screens.length === 0)
            return Qt.rect(0, 0, 0, 0);

        const left = Math.min(...screens.map(screen => screen.x));
        const top = Math.min(...screens.map(screen => screen.y));
        const right = Math.max(...screens.map(screen => screen.x + screen.width));
        const bottom = Math.max(...screens.map(screen => screen.y + screen.height));

        return Qt.rect(left, top, right - left, bottom - top);
    }

    function setFit(path: string, fit: string): void {
        if (!path || !WallpaperFit.values.includes(fit) || root.fitFor(path) === fit)
            return;

        const next = Object.assign({}, root.fits);
        if (fit === WallpaperFit.fill)
            delete next[path];
        else
            next[path] = fit;

        root.fits = next;

        if (root.fitsLoaded)
            fitDebounce.restart();
    }

    function adoptFits(payload: string): void {
        if (root.fitsLoaded)
            return;

        try {
            root.fits = JSON.parse(payload) ?? {};
        } catch (parseError) {
            root.fits = {};
        }

        root.fitsLoaded = true;
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
        root.fallback();
    }

    function fallback(): void {
        if (root.missing && !root.committed && root.paths.length > 0)
            root.set(root.paths[0]);
    }

    function discard(): void {
        root.missing = true;
        root.committed = "";
        root.current = "";
        root.fallback();
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

        command: ["find", "-L", root.imageDir, "-maxdepth", "1", "-type", "f"]

        stdout: StdioCollector {
            onStreamFinished: root.apply(text)
        }
    }

    Process {
        id: verify

        command: ["test", "-f", root.committed]

        onExited: code => {
            if (code !== 0)
                root.discard();
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
                verify.running = true;
            }
        }

        onLoadFailed: {
            root.missing = true;
            root.fallback();
        }
    }

    Timer {
        id: fitDebounce

        interval: Appearance.wallpaper.fitSaveDebounce

        onTriggered: fitStore.setText(JSON.stringify(root.fits))
    }

    FileView {
        id: fitStore

        path: root.ready ? root.fitPath : ""
        atomicWrites: true
        printErrors: false

        onLoaded: root.adoptFits(text())
        onLoadFailed: root.fitsLoaded = true
    }

    Component.onCompleted: root.refresh()
}
