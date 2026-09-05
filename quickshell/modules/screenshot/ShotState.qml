pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers

Singleton {
    id: root

    property bool opened: false
    property string search: ""
    property string pending: ""

    readonly property var actions: [
        {
            action: ShotAction.region,
            icon: Icons.shotRegion,
            label: Appearance.shot.regionLabel,
            subtitle: Appearance.shot.regionSubtitle
        },
        {
            action: ShotAction.fullscreen,
            icon: Icons.shotFullscreen,
            label: Appearance.shot.fullscreenLabel,
            subtitle: Appearance.shot.fullscreenSubtitle
        },
        {
            action: ShotAction.ocr,
            icon: Icons.shotOcr,
            label: Appearance.shot.ocrLabel,
            subtitle: Appearance.shot.ocrSubtitle
        }
    ]

    readonly property string dir: `${Paths.home}/${Appearance.shot.dir}`

    readonly property var results: {
        const query = root.search.trim().toLowerCase();
        if (!query)
            return root.actions;

        return root.actions.filter(entry => entry.label.toLowerCase().includes(query));
    }

    function edit(text: string): void {
        root.search = text;
    }

    function show(): void {
        root.search = "";
        root.opened = true;
    }

    function hide(): void {
        root.opened = false;
    }

    function toggle(): void {
        if (root.opened)
            root.hide();
        else
            root.show();
    }

    function activate(entry): void {
        if (!entry)
            return;

        root.pending = entry.action;
        root.hide();
        capture.restart();
    }

    function run(action: string): void {
        const file = Qt.formatDateTime(new Date(), Appearance.shot.fileFormat);

        if (action === ShotAction.region)
            Quickshell.execDetached(["sh", "-c", Commands.shotRegion.arg(root.dir).arg(file)]);
        else if (action === ShotAction.fullscreen)
            Quickshell.execDetached(["sh", "-c", Commands.shotFullscreen.arg(root.dir).arg(file).arg(Appearance.shot.fullscreenDelay)]);
        else if (action === ShotAction.ocr)
            Quickshell.execDetached(["sh", "-c", Commands.shotOcr]);
    }

    Timer {
        id: capture

        interval: Appearance.shot.captureDelay

        onTriggered: {
            root.run(root.pending);
            root.pending = "";
        }
    }
}
