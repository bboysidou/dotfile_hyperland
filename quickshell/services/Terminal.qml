pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property string name: Terminals.fallback

    readonly property var flags: Terminals.flags[root.name] ?? Terminals.unknown

    function command(job: var): var {
        const title = job.title ? root.flags.title.map(part => part.arg(job.title)) : [];
        const hold = job.hold ? root.flags.hold : [];
        return [root.name].concat(title, hold, root.flags.exec, job.program);
    }

    function adopt(source: string): void {
        const match = source.match(Terminals.namePattern);
        root.name = match ? match[1] : Terminals.fallback;
    }

    FileView {
        path: Paths.terminal
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoaded: root.adopt(text())
        onLoadFailed: root.name = Terminals.fallback
    }
}
