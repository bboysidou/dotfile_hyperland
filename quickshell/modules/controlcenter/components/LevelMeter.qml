import QtQuick
import Quickshell.Services.Pipewire
import qs.core.components
import qs.core.config
import qs.core.helpers

Item {
    id: root

    property var node: null
    property color accent: Colours.audioOutput
    property bool muted: false

    readonly property bool live: root.visible && !!root.node
    readonly property real target: root.live ? root.scaled(monitor.peak) : 0
    property real level: 0
    property real hold: 0
    property real heldAt: 0
    readonly property bool sounding: root.hold > 0

    function scaled(peak: real): real {
        const config = Appearance.audioPanel;
        if (peak <= 0)
            return 0;
        const db = config.meterDbScale * Math.log10(peak);
        return Num.clamp01(1 - db / config.meterFloorDb);
    }

    function tick(): void {
        const config = Appearance.audioPanel;
        const now = Date.now();
        root.level = Math.max(root.target, root.level - config.meterRelease);
        if (root.target >= root.hold) {
            root.hold = root.target;
            root.heldAt = now;
        } else if (now - root.heldAt > config.meterHoldDuration) {
            root.hold = Math.max(root.level, root.hold - config.meterHoldRelease);
        }
    }

    implicitHeight: Appearance.audioPanel.meterThickness
    opacity: root.muted ? Appearance.audioPanel.meterMutedOpacity : 1

    onLiveChanged: {
        if (!root.live) {
            root.level = 0;
            root.hold = 0;
        }
    }

    PwNodePeakMonitor {
        id: monitor

        node: root.node
        enabled: root.live
    }

    Timer {
        running: root.live && (root.target > 0 || root.level > 0 || root.hold > 0)
        repeat: true
        interval: Appearance.audioPanel.meterInterval

        onTriggered: root.tick()
    }

    Meter {
        anchors.fill: parent

        value: root.level
        minFill: 0
        thickness: Appearance.audioPanel.meterThickness
        fillColour: root.muted ? Colours.textMuted : root.accent
    }

    StyledRect {
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        x: Math.max(0, root.hold * root.width - width)
        width: Appearance.audioPanel.meterHoldWidth
        color: root.muted ? Colours.textMuted : root.accent
        visible: root.hold > 0
    }
}
