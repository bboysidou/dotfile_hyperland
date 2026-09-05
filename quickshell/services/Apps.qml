pragma Singleton

import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    readonly property string cacheDir: `${Paths.cache}/${Appearance.launcher.usageCacheDir}`
    readonly property string cachePath: `${root.cacheDir}/${Appearance.launcher.usageCacheFile}`

    property var usage: ({})

    readonly property var entries: DesktopEntries.applications.values.filter(entry => !entry.noDisplay)

    function score(entry, needle: string): int {
        const name = Str.fold(entry.name);

        if (name === needle)
            return Appearance.launcher.scoreExact;

        if (name.startsWith(needle))
            return Appearance.launcher.scorePrefix;

        if (Str.words(name).some(word => word.startsWith(needle)))
            return Appearance.launcher.scoreWordPrefix;

        if (name.includes(needle))
            return Appearance.launcher.scoreSubstring;

        if ([entry.genericName, ...entry.keywords].some(value => Str.fold(value).includes(needle)))
            return Appearance.launcher.scoreMeta;

        if (Str.fold(entry.comment).includes(needle))
            return Appearance.launcher.scoreComment;

        if (Str.isSubsequence(needle, name))
            return Appearance.launcher.scoreSubsequence;

        return 0;
    }

    function count(entry): int {
        return root.usage[entry.id] ?? 0;
    }

    function query(text: string): var {
        const needle = Str.fold(text).trim();
        const ranked = [];

        for (const entry of root.entries) {
            const rank = needle.length === 0 ? Appearance.launcher.scoreExact : root.score(entry, needle);

            if (rank > 0)
                ranked.push({
                    entry,
                    rank
                });
        }

        ranked.sort((a, b) => b.rank - a.rank || root.count(b.entry) - root.count(a.entry) || a.entry.name.localeCompare(b.entry.name));

        return ranked.map(item => item.entry);
    }

    function register(id: string): void {
        const next = Object.assign({}, root.usage);
        next[id] = (next[id] ?? 0) + 1;
        root.usage = next;
        cache.setText(JSON.stringify(next));
    }

    function adopt(payload: string): void {
        let parsed;

        try {
            parsed = JSON.parse(payload);
        } catch (e) {
            console.warn("Apps: usage cache is not valid JSON, starting empty");
            return;
        }

        if (!parsed || typeof parsed !== "object")
            return;

        root.usage = parsed;
    }

    Process {
        running: true

        command: ["mkdir", "-p", root.cacheDir]
    }

    FileView {
        id: cache

        path: root.cachePath
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
    }
}
