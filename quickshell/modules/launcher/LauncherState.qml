pragma Singleton

import Quickshell
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string mode: LauncherMode.apps
    property string search: ""

    readonly property bool wallpaperMode: root.mode === LauncherMode.wallpapers
    readonly property bool themeMode: root.mode === LauncherMode.themes
    readonly property bool clipboardMode: root.mode === LauncherMode.clipboard
    readonly property string wallpaperTrigger: `${Appearance.launcher.actionPrefix}${Appearance.launcher.wallpaperAction} `
    readonly property string themeTrigger: `${Appearance.launcher.actionPrefix}${Appearance.launcher.themeAction} `
    readonly property string clipboardTrigger: `${Appearance.launcher.actionPrefix}${Appearance.clipboard.action} `

    function edit(text: string): void {
        if (root.mode === LauncherMode.apps && text.startsWith(root.wallpaperTrigger)) {
            root.enterWallpapers(text.slice(root.wallpaperTrigger.length));
            return;
        }

        if (root.mode === LauncherMode.apps && text.startsWith(root.themeTrigger)) {
            root.enterThemes(text.slice(root.themeTrigger.length));
            return;
        }

        if (root.mode === LauncherMode.apps && text.startsWith(root.clipboardTrigger)) {
            root.enterClipboard(text.slice(root.clipboardTrigger.length));
            return;
        }

        root.search = text;
    }

    function enterWallpapers(query: string): void {
        Wallpaper.refresh();
        root.mode = LauncherMode.wallpapers;
        root.search = query;
    }

    function enterThemes(query: string): void {
        root.mode = LauncherMode.themes;
        root.search = query;
    }

    function enterClipboard(query: string): void {
        Clipboard.refresh();
        root.mode = LauncherMode.clipboard;
        root.search = query;
    }

    function show(): void {
        root.mode = LauncherMode.apps;
        root.search = "";
        root.opened = true;
    }

    function showWallpapers(): void {
        root.enterWallpapers("");
        root.opened = true;
    }

    function showThemes(): void {
        root.enterThemes("");
        root.opened = true;
    }

    function toggleWallpapers(): void {
        if (root.opened && root.wallpaperMode)
            root.hide();
        else
            root.showWallpapers();
    }

    function toggleThemes(): void {
        if (root.opened && root.themeMode)
            root.hide();
        else
            root.showThemes();
    }

    function showClipboard(): void {
        root.enterClipboard("");
        root.opened = true;
    }

    function toggleClipboard(): void {
        if (root.opened && root.clipboardMode)
            root.hide();
        else
            root.showClipboard();
    }

    function hide(): void {
        Wallpaper.stopPreview();
        Theme.stopPreview();
        root.opened = false;
    }

    function toggle(): void {
        if (root.opened && root.mode === LauncherMode.apps)
            root.hide();
        else
            root.show();
    }

    function activateWallpaper(path: string): void {
        if (!path)
            return;

        Wallpaper.set(path);
        root.hide();
    }

    function chordWallpaper(key: int, path: string): bool {
        const fit = WallpaperFit.fromKey(key);
        if (!root.wallpaperMode || !fit || !path)
            return false;

        Wallpaper.setFit(path, fit);
        return true;
    }

    function activateTheme(name: string): void {
        if (!name)
            return;

        Theme.set(name);
        root.hide();
    }

    function activateClip(entry): void {
        if (!entry)
            return;

        Clipboard.copy(entry.id);
        root.hide();
    }

    function removeClip(entry, all: bool): void {
        if (all)
            Clipboard.wipe();
        else if (entry)
            Clipboard.remove(entry.id);
    }

    function activate(entry): void {
        if (!entry)
            return;

        Apps.register(entry.id);

        if (entry.runInTerminal)
            Launch.app(Terminal.command({
                program: entry.command,
                title: "",
                hold: false
            }), entry.workingDirectory);
        else
            Launch.app(entry.command, entry.workingDirectory);

        root.hide();
    }
}
