pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers

Singleton {
    id: root

    property bool opened: false
    property string fifo: ""
    property string section: ShareSource.screen
    property int index: 0
    property bool remember: false
    property var windows: []

    readonly property var tabs: [
        {
            section: ShareSource.screen,
            icon: Icons.shareScreen,
            label: Appearance.share.screensLabel
        },
        {
            section: ShareSource.window,
            icon: Icons.shareWindow,
            label: Appearance.share.windowsLabel
        }
    ]

    readonly property var screens: Quickshell.screens.map(screen => ({
                source: ShareSource.screen,
                id: screen.name,
                title: screen.name,
                subtitle: Appearance.share.resolutionTemplate.arg(screen.width).arg(screen.height),
                icon: "",
                capture: screen
            }))

    readonly property var entries: root.section === ShareSource.screen ? root.screens : root.windows
    readonly property var current: root.entries[root.index] ?? null

    function entry(chunk: string): var {
        const classAt = chunk.indexOf(Xdph.classSeparator);
        const titleAt = chunk.indexOf(Xdph.titleSeparator);
        const addressAt = chunk.indexOf(Xdph.addressSeparator);
        const appClass = chunk.slice(classAt + Xdph.classSeparator.length, titleAt);
        const title = chunk.slice(titleAt + Xdph.titleSeparator.length, addressAt);
        const address = Number(chunk.slice(addressAt + Xdph.addressSeparator.length));
        const toplevel = Hyprland.toplevels.values.find(candidate => parseInt(candidate.address, 16) === address);

        return {
            source: ShareSource.window,
            id: chunk.slice(0, classAt),
            title: title || appClass,
            subtitle: appClass,
            icon: Fmt.icon(DesktopEntries.heuristicLookup(appClass)?.icon ?? appClass),
            capture: toplevel?.wayland ?? null
        };
    }

    function parse(list: string): var {
        return list.split(Xdph.entryEnd).filter(chunk => chunk.includes(Xdph.addressSeparator)).map(chunk => root.entry(chunk));
    }

    function open(fifo: string, list: string, token: bool): void {
        root.cancel();
        Hyprland.refreshToplevels();

        root.fifo = fifo;
        root.windows = root.parse(list);
        root.remember = token;
        root.show(ShareSource.screen);
        root.index = Math.max(0, root.screens.findIndex(screen => screen.id === Monitors.focused));
        root.opened = true;
    }

    function show(section: string): void {
        root.section = section;
        root.index = 0;
    }

    function cycle(): void {
        const at = ShareSource.values.indexOf(root.section);

        root.show(ShareSource.values[(at + 1) % ShareSource.values.length]);
    }

    function select(index: int): void {
        if (index >= 0 && index < root.entries.length)
            root.index = index;
    }

    function step(delta: int): void {
        root.select(root.index + delta);
    }

    function selection(target: string): string {
        return `${Xdph.selection}${root.remember ? Xdph.tokenFlag : ""}${Xdph.flagEnd}${target}`;
    }

    function write(fifo: string, text: string): void {
        if (fifo)
            Quickshell.execDetached(["timeout", String(Appearance.share.replyTimeout), "sh", "-c", Commands.shareReply, "sh", text, fifo]);
    }

    function reply(text: string): void {
        root.write(root.fifo, text);
        root.fifo = "";
        root.opened = false;
    }

    function share(): void {
        if (root.current)
            root.reply(root.selection(`${root.current.source}${Xdph.targetSeparator}${root.current.id}`));
    }

    function cancel(): void {
        root.reply("");
    }

    function dismiss(): void {
        if (root.opened)
            root.cancel();
    }

    function abandon(): void {
        root.fifo = "";
        root.opened = false;
    }

    function pickRegion(): void {
        if (!root.fifo)
            return;

        region.target = root.fifo;
        root.fifo = "";
        root.opened = false;
        region.running = true;
    }

    function finishRegion(text: string): void {
        const [output, x, y, width, height] = text.trim().split(" ");
        const screen = Quickshell.screens.find(candidate => candidate.name === output);

        if (!screen || !height) {
            root.write(region.target, "");
            return;
        }

        const local = [Number(x) - screen.x, Number(y) - screen.y, width, height].join(",");

        root.write(region.target, root.selection(`${Xdph.region}${Xdph.targetSeparator}${output}@${local}`));
    }

    Process {
        id: region

        property string target: ""

        command: ["timeout", String(Appearance.share.regionTimeout), ...Commands.shareRegion]

        stdout: StdioCollector {
            id: picked
        }

        onExited: code => code === 0 ? root.finishRegion(picked.text) : root.write(region.target, "")
    }
}
