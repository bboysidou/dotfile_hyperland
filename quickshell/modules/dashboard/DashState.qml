pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.enums
import qs.core.helpers

Singleton {
    id: root

    readonly property var sections: [DashSection.dash, DashSection.performance, DashSection.media]

    property bool pinned: false
    property bool barHover: false
    property bool panelHover: false
    property bool lingering: false
    property string tab: DashSection.dash

    readonly property bool hovering: root.barHover || root.panelHover
    readonly property bool opened: root.pinned || root.lingering
    readonly property int index: Math.max(0, root.sections.indexOf(root.tab))

    function show(section: string): void {
        if (section.length > 0)
            root.tab = section;

        root.pinned = true;
    }

    function hide(): void {
        linger.stop();
        root.pinned = false;
        root.lingering = false;
    }

    function toggle(section: string): void {
        if (root.pinned)
            root.hide();
        else
            root.show(section);
    }

    function step(delta: int): void {
        root.tab = root.sections[Num.clamp(root.index + delta, 0, root.sections.length - 1)];
    }

    onHoveringChanged: {
        if (root.hovering) {
            linger.stop();
            root.lingering = true;
        } else {
            linger.restart();
        }
    }

    Timer {
        id: linger

        interval: Appearance.dash.hoverCloseDelay

        onTriggered: {
            if (!root.hovering)
                root.lingering = false;
        }
    }
}
