pragma Singleton

import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    readonly property string cacheDir: `${Paths.cache}/${Appearance.clipboard.cacheDir}`
    readonly property var binaryPattern: /^\[\[ binary data (.+) (\w+) (\d+)x(\d+) \]\]$/

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
        root.entries = payload.split("\n").map(root.entry).filter(item => item !== null).slice(0, Appearance.clipboard.maxEntries);

        const images = root.entries.filter(item => item.image).map(item => item.id);

        decoder.images = images;
        decoder.command = ["sh", "-c", Commands.clipThumbs, "sh", root.cacheDir].concat(images);
        decoder.running = true;
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
        root.mutate(Commands.clipWipe);
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
