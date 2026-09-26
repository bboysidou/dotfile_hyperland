pragma Singleton

import Quickshell
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string mode: LauncherMode.apps
    property string search: ""

    readonly property bool wallpaperMode: root.mode === LauncherMode.wallpapers
    readonly property bool themeMode: root.mode === LauncherMode.themes
    readonly property string wallpaperTrigger: `${Appearance.launcher.actionPrefix}${Appearance.launcher.wallpaperAction} `
    readonly property string themeTrigger: `${Appearance.launcher.actionPrefix}${Appearance.launcher.themeAction} `

    function edit(text: string): void {
        if (root.mode === LauncherMode.apps && text.startsWith(root.wallpaperTrigger)) {
            root.enterWallpapers(text.slice(root.wallpaperTrigger.length));
            return;
        }

        if (root.mode === LauncherMode.apps && text.startsWith(root.themeTrigger)) {
            root.enterThemes(text.slice(root.themeTrigger.length));
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

    function activateTheme(name: string): void {
        if (!name)
            return;

        Theme.set(name);
        root.hide();
    }

    function activate(entry): void {
        if (!entry)
            return;

        Apps.register(entry.id);

        if (entry.runInTerminal)
            Quickshell.execDetached(Commands.terminal.concat(entry.command));
        else
            entry.execute();

        root.hide();
    }
}
