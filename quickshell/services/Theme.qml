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
    readonly property string statePath: `${root.stateDir}/${Appearance.theme.stateFile}`

    property string committed: ThemeName.defaultTheme
    property string current: ThemeName.defaultTheme

    function isValid(name: string): bool {
        return ThemeName.values.includes(name);
    }

    function set(name: string): bool {
        if (!root.isValid(name))
            return false;

        root.committed = name;
        root.current = name;
        store.setText(JSON.stringify({
            theme: name
        }));
        return true;
    }

    function preview(name: string): void {
        if (root.isValid(name))
            root.current = name;
    }

    function stopPreview(): void {
        root.current = root.committed;
    }

    function cycle(delta: int): string {
        const index = ThemeName.values.indexOf(root.committed);
        const next = ThemeName.values[Num.wrap(index, delta, ThemeName.values.length)];
        root.set(next);
        return next;
    }

    function label(name: string): string {
        return Appearance.theme.labels[name] ?? name;
    }

    function query(search: string): var {
        if (!search)
            return ThemeName.values;

        return ThemeName.values.filter(name => Str.contains(root.label(name), search));
    }

    function adopt(payload: string): void {
        let name = ThemeName.defaultTheme;
        try {
            name = JSON.parse(payload).theme ?? name;
        } catch (parseError) {
            name = ThemeName.defaultTheme;
        }

        const valid = root.isValid(name) ? name : ThemeName.defaultTheme;
        root.committed = valid;
        root.current = valid;
    }

    Binding {
        target: Colours
        property: "theme"
        value: root.current
    }

    Process {
        command: ["mkdir", "-p", root.stateDir]
        running: true
    }

    FileView {
        id: store

        path: root.statePath
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
    }
}
