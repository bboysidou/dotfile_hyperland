pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    readonly property string cacheDir: `${Paths.cache}/${Appearance.clipboard.cacheDir}`
    readonly property var binaryPattern: /^\[\[ binary data (.+) (\w+) (\d+)x(\d+) \]\]$/
    readonly property string configPath: `${Paths.config}/cliphist/config`
    readonly property bool ready: root.recording && Prefs.loaded

    property bool recording: false
    property bool agesLoaded: false
    property var ages: ({})
    property int total: 0
    property var entries: []
    property var thumbs: ({})
    property var pending: []

    function entry(line: string): var {
        const tab = line.indexOf("\t");

        if (tab <= 0)
            return null;

        const id = line.slice(0, tab);
        const preview = line.slice(tab + 1);
        const binary = preview.match(root.binaryPattern);

        if (!binary)
            return {
                id,
                image: false,
                label: Str.oneLine(preview),
                thumb: ""
            };

        return {
            id,
            image: true,
            label: `${binary[2].toUpperCase()} · ${binary[3]}×${binary[4]} · ${binary[1]}`,
            thumb: `${root.cacheDir}/${id}`
        };
    }

    function adopt(payload: string): void {
        const all = payload.split("\n").map(root.entry).filter(item => item !== null);

        root.total = all.length;
        root.entries = all.slice(0, Appearance.clipboard.maxEntries);
        root.stamp(all.map(item => item.id));

        const images = root.entries.filter(item => item.image).map(item => item.id);

        decoder.images = images;
        decoder.command = ["sh", "-c", Commands.clipThumbs, "sh", root.cacheDir].concat(images);
        decoder.running = true;
    }

    function stamp(ids: var): void {
        if (!root.agesLoaded)
            return;

        const now = Date.now();
        const next = {};

        for (const id of ids)
            next[id] = root.ages[id] ?? now;

        if (JSON.stringify(next) !== JSON.stringify(root.ages)) {
            root.ages = next;
            agesFile.setText(JSON.stringify(next));
        }

        root.expire(ids);
    }

    function expire(ids: var): void {
        if (Prefs.clipMaxDays <= 0)
            return;

        const cutoff = Date.now() - Prefs.clipMaxDays * Units.msPerDay;
        const stale = ids.filter(id => root.ages[id] < cutoff);

        if (stale.length === 0)
            return;

        root.entries = root.entries.filter(item => !stale.includes(item.id));
        root.mutate(["sh", "-c", Commands.clipDeleteMany, "sh"].concat(stale));
    }

    function writeConfig(): void {
        if (root.ready)
            root.mutate(["sh", "-c", Commands.clipConfig, "sh", root.configPath, String(Prefs.clipMaxItems)]);
    }

    function query(text: string): var {
        const needle = text.trim();

        if (needle.length === 0)
            return root.entries;

        return root.entries.filter(item => Str.contains(item.label, needle));
    }

    function refresh(): void {
        lister.running = true;
    }

    function copy(id: string): void {
        if (!id)
            return;

        Quickshell.execDetached(["sh", "-c", Commands.clipCopy, "sh", id]);
    }

    function drain(): void {
        if (mutator.running || root.pending.length === 0)
            return;

        mutator.command = root.pending[0];
        root.pending = root.pending.slice(1);
        mutator.running = true;
    }

    function mutate(command: var): void {
        root.pending = root.pending.concat([command]);
        root.drain();
    }

    function remove(id: string): void {
        if (!id)
            return;

        root.entries = root.entries.filter(item => item.id !== id);
        root.mutate(["sh", "-c", Commands.clipDelete, "sh", id]);
    }

    function wipe(): void {
        root.entries = [];
        root.total = 0;
        root.mutate(Commands.clipWipe);
    }

    onReadyChanged: root.writeConfig()

    Connections {
        target: Prefs

        function onClipMaxItemsChanged(): void {
            root.writeConfig();
        }

        function onClipMaxDaysChanged(): void {
            root.refresh();
        }
    }

    Process {
        running: root.ready
        command: Commands.clipWatchText
    }

    Process {
        running: root.ready && Prefs.clipImages
        command: Commands.clipWatchImage
    }

    Timer {
        running: root.recording && root.agesLoaded
        interval: Appearance.clipboard.sweepInterval
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

    FileView {
        id: agesFile

        path: `${Prefs.stateDir}/${Appearance.clipboard.agesFile}`
        atomicWrites: true
        printErrors: false

        onLoaded: {
            try {
                root.ages = JSON.parse(agesFile.text());
            } catch (parseError) {}
            root.agesLoaded = true;
        }
        onLoadFailed: root.agesLoaded = true
    }

    Process {
        id: mutator

        onExited: {
            if (root.pending.length > 0)
                root.drain();
            else
                root.refresh();
        }
    }

    Process {
        id: lister

        command: Commands.clipList

        stdout: StdioCollector {
            onStreamFinished: root.adopt(text)
        }
    }

    Process {
        id: decoder

        property var images: []

        onExited: {
            const ready = {};

            for (const id of decoder.images)
                ready[id] = true;

            root.thumbs = ready;
        }
    }
}
