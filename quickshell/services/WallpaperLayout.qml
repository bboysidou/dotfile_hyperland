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

    property bool linked: true
    property string target: ""
    property var screens: ({})
    property var previews: ({})
    property var fits: ({})
    property var screenFits: ({})
    property bool fitsLoaded: false
    property bool layoutLoaded: false

    readonly property var ordered: [...Quickshell.screens].sort((a, b) => a.x - b.x || a.y - b.y)

    function screenFor(name: string): var {
        return Quickshell.screens.find(screen => screen.name === name) ?? Quickshell.screens[0] ?? null;
    }

    function committedFor(name: string): string {
        return root.linked ? Wallpaper.committed : root.screens[name] ?? Wallpaper.committed;
    }

    function currentFor(name: string): string {
        return root.linked ? Wallpaper.current : root.previews[name] ?? root.committedFor(name);
    }

    function preview(path: string): void {
        if (!path)
            return;

        if (root.linked)
            Wallpaper.preview(path);
        else
            root.previews = Object.assign({}, root.previews, {
                [root.target]: path
            });
    }

    function stopPreview(): void {
        Wallpaper.stopPreview();
        root.previews = {};
    }

    function set(path: string): void {
        if (!path)
            return;

        if (root.linked) {
            Wallpaper.set(path);
            return;
        }

        root.screens = Object.assign({}, root.screens, {
            [root.target]: path
        });
        root.persistLayout();
    }

    function setLinked(on: bool): void {
        if (root.linked === on)
            return;

        if (on)
            Wallpaper.set(root.committedFor(root.target));

        root.stopPreview();
        root.linked = on;
        root.persistLayout();
    }

    function pick(index: int): bool {
        const screen = root.ordered[index];
        if (root.linked || !screen)
            return false;

        root.stopPreview();
        root.target = screen.name;
        return true;
    }

    function fitFor(path: string, name: string): string {
        const fit = (root.linked ? null : root.screenFits[name]?.[path]) ?? root.fits[path] ?? WallpaperFit.fill;
        return fit === WallpaperFit.span && !root.linked ? WallpaperFit.fill : fit;
    }

    function fillModeFor(path: string, name: string): int {
        return WallpaperFit.fillModes[root.fitFor(path, name)];
    }

    function isUnscaled(path: string, name: string): bool {
        return WallpaperFit.unscaled.includes(root.fitFor(path, name));
    }

    function spans(path: string, name: string): bool {
        return root.fitFor(path, name) === WallpaperFit.span;
    }

    function fitsAvailable(): var {
        return root.linked ? WallpaperFit.values : WallpaperFit.values.filter(fit => fit !== WallpaperFit.span);
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
        if (!path || !root.fitsAvailable().includes(fit) || root.fitFor(path, root.target) === fit)
            return;

        if (root.linked)
            root.fits = root.without(root.fits, path, fit, WallpaperFit.fill);
        else
            root.screenFits = Object.assign({}, root.screenFits, {
                [root.target]: root.without(root.screenFits[root.target] ?? {}, path, fit, root.fits[path] ?? WallpaperFit.fill)
            });

        if (root.fitsLoaded)
            fitDebounce.restart();
    }

    function without(map: var, path: string, fit: string, fallback: string): var {
        const next = Object.assign({}, map);
        if (fit === fallback)
            delete next[path];
        else
            next[path] = fit;

        return next;
    }

    function adoptFits(payload: string): void {
        if (root.fitsLoaded)
            return;

        try {
            const state = JSON.parse(payload) ?? {};
            const nested = "fits" in state;
            root.fits = nested ? state.fits : state;
            root.screenFits = nested ? state.screens ?? {} : {};
        } catch (parseError) {}

        root.fitsLoaded = true;
    }

    function adoptLayout(payload: string): void {
        if (root.layoutLoaded)
            return;

        try {
            const state = JSON.parse(payload) ?? {};
            root.linked = state.linked ?? true;
            root.screens = state.screens ?? {};
        } catch (parseError) {}

        root.layoutLoaded = true;
    }

    function persistLayout(): void {
        if (root.layoutLoaded)
            layoutStore.setText(JSON.stringify({
                linked: root.linked,
                screens: root.screens
            }));
    }

    Timer {
        id: fitDebounce

        interval: Appearance.wallpaper.fitSaveDebounce

        onTriggered: fitStore.setText(JSON.stringify({
            fits: root.fits,
            screens: root.screenFits
        }))
    }

    Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: fitStore

        path: `${root.stateDir}/${Appearance.wallpaper.fitStateFile}`
        atomicWrites: true
        printErrors: false

        onLoaded: root.adoptFits(text())
        onLoadFailed: root.fitsLoaded = true
    }

    FileView {
        id: layoutStore

        path: `${root.stateDir}/${Appearance.wallpaper.layoutStateFile}`
        atomicWrites: true
        printErrors: false

        onLoaded: root.adoptLayout(text())
        onLoadFailed: root.layoutLoaded = true
    }
}
