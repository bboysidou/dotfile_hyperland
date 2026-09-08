pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property string source: ""

    readonly property var entries: root.source ? Lua.binds(root.source).map(bind => ({
                section: Keymap.words(bind.section) || Appearance.keybinds.labelOther,
                chord: Keymap.chord(bind.chord),
                through: bind.through ? Keymap.tail(bind.through) : "",
                label: Keymap.label(bind.action)
            })) : []

    readonly property var sections: {
        const order = [];
        const grouped = new Map();

        for (const entry of root.entries) {
            if (!grouped.has(entry.section)) {
                grouped.set(entry.section, []);
                order.push(entry.section);
            }

            grouped.get(entry.section).push(entry);
        }

        return order.map(title => ({
                    title,
                    binds: grouped.get(title)
                }));
    }

    readonly property int count: root.entries.length

    function columns(count: int): var {
        const buckets = [];
        const weights = [];

        for (let index = 0; index < count; index++) {
            buckets.push([]);
            weights.push(0);
        }

        for (const section of root.sections) {
            let target = 0;

            for (let index = 1; index < count; index++)
                if (weights[index] < weights[target])
                    target = index;

            buckets[target].push(section);
            weights[target] += section.binds.length + Appearance.keybinds.headingWeight;
        }

        return buckets;
    }

    FileView {
        path: Paths.keymaps
        watchChanges: true

        onFileChanged: reload()
        onLoaded: root.source = text()
    }
}
