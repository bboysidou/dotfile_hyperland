pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.helpers

Singleton {
    id: root

    property bool active: false
    property var modules: []

    function apply(payload: string): void {
        root.modules = payload.trim().split("\n").filter(line => line.length > 0).map(line => {
            const parts = line.split("\t");

            return {
                locator: parts[0] ?? "",
                size: parts[1] ?? "",
                type: parts[2] ?? "",
                speed: parts[3] ?? ""
            };
        });
    }

    onActiveChanged: {
        if (root.active)
            file.reload();
    }

    FileView {
        id: file

        path: Paths.dimms
        printErrors: false
        onLoaded: root.apply(text())
        onLoadFailed: root.modules = []
    }
}
