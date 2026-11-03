pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.constants
import qs.core.enums

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
            action: ShotAction.monitor,
            icon: Icons.monitor,
            label: Appearance.shot.monitorLabel,
            subtitle: Appearance.shot.monitorSubtitle
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
        if (action === ShotAction.region)
            ScreenshotState.open(ScreenshotMode.smart);
        else if (action === ShotAction.monitor)
            ScreenshotState.open(ScreenshotMode.monitor);
        else if (action === ShotAction.fullscreen)
            ScreenshotState.open(ScreenshotMode.all);
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
