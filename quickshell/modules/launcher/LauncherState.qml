pragma Singleton

import Quickshell
import qs.core.config
import qs.core.constants
import qs.services

Singleton {
    id: root

    property bool opened: false
    property bool wallpaperMode: false
    property string search: ""

    readonly property string wallpaperTrigger: `${Appearance.launcher.actionPrefix}${Appearance.launcher.wallpaperAction} `

    function edit(text: string): void {
        if (!root.wallpaperMode && text.startsWith(root.wallpaperTrigger)) {
            root.enterWallpapers(text.slice(root.wallpaperTrigger.length));
            return;
        }

        root.search = text;
    }

    function enterWallpapers(query: string): void {
        Wallpaper.refresh();
        root.wallpaperMode = true;
        root.search = query;
    }

    function show(): void {
        root.wallpaperMode = false;
        root.search = "";
        root.opened = true;
    }

    function showWallpapers(): void {
        root.enterWallpapers("");
        root.opened = true;
    }

    function toggleWallpapers(): void {
        if (root.opened && root.wallpaperMode)
            root.hide();
        else
            root.showWallpapers();
    }

    function hide(): void {
        Wallpaper.stopPreview();
        root.opened = false;
    }

    function toggle(): void {
        if (root.opened && !root.wallpaperMode)
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
