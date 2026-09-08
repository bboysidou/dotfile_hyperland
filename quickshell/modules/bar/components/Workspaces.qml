pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.core.components
import qs.core.config
import qs.core.enums

Item {
    id: root

    readonly property var slotIds: {
        const ids = Hyprland.workspaces.values.map(ws => ws.id).filter(id => id > 0);

        for (let id = 1; id <= Appearance.bar.workspacesMinimum; id++)
            if (!ids.includes(id))
                ids.push(id);

        return ids.sort((a, b) => a - b);
    }

    readonly property int pillSize: Appearance.slider.thickness
    readonly property int pillRounding: Math.round(root.pillSize * Appearance.slider.roundingRatio)
    readonly property int activeId: Hyprland.focusedWorkspace?.id ?? -1

    property bool introDone: false
    property real wheelDelta: 0

    function activate(id: int): void {
        Hyprland.dispatch(Hyprland.usingLua ? `hl.dsp.focus({ workspace = ${id} })` : `workspace ${id}`);
    }

    function step(direction: int): void {
        const count = root.slotIds.length;
        if (count < 2)
            return;

        const from = root.slotIds.indexOf(root.activeId);
        const next = from < 0 ? (direction > 0 ? 0 : count - 1) : (from + direction + count) % count;

        root.activate(root.slotIds[next]);
    }

    Layout.leftMargin: Appearance.bar.workspaceMarginLeft

    implicitWidth: row.implicitWidth
    implicitHeight: root.pillSize

    Timer {
        running: true
        interval: root.slotIds.length * Appearance.bar.workspaceStaggerStep + Appearance.bar.workspaceStaggerDelay
        onTriggered: root.introDone = true
    }

    Timer {
        id: wheelReset

        interval: Appearance.bar.workspaceWheelReset
        onTriggered: root.wheelDelta = 0
    }

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
            wheelReset.restart();
            root.wheelDelta += wheel.angleDelta.y;

            const threshold = Appearance.bar.workspaceWheelThreshold;
            if (Math.abs(root.wheelDelta) < threshold)
                return;

            const steps = Math.trunc(root.wheelDelta / threshold);
            root.wheelDelta %= threshold;
            root.step(steps > 0 ? -1 : 1);
        }
    }

    Row {
        id: row

        anchors.verticalCenter: parent.verticalCenter

        spacing: Appearance.bar.workspacePillSpacing

        Repeater {
            model: root.slotIds

            MouseArea {
                id: slot

                required property int index
                required property var modelData

                readonly property int workspaceId: modelData
                readonly property var workspace: Hyprland.workspaces.values.find(ws => ws.id === slot.workspaceId) ?? null
                readonly property bool occupied: (slot.workspace?.toplevels?.values?.length ?? 0) > 0
                readonly property bool active: root.activeId === slot.workspaceId
                readonly property bool urgent: slot.workspace?.urgent ?? false

                property bool entered: false

                width: slot.active ? Appearance.bar.workspacePillActiveWidth : root.pillSize
                height: root.pillSize

                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                opacity: slot.entered ? 1 : 0

                onClicked: root.activate(slot.workspaceId)

                Component.onCompleted: {
                    if (root.introDone)
                        slot.entered = true;
                    else
                        stagger.start();
                }

                Behavior on width {
                    Anim {
                        duration: Appearance.bar.workspaceExtendDuration
                        type: AnimType.standard
                    }
                }

                Behavior on opacity {
                    Anim {
                        type: AnimType.standardLarge
                    }
                }

                transform: Translate {
                    y: slot.entered ? 0 : root.pillSize

                    Behavior on y {
                        Anim {
                            type: AnimType.standardLarge
                        }
                    }
                }

                Timer {
                    id: stagger

                    interval: slot.index * Appearance.bar.workspaceStaggerStep + Appearance.bar.workspaceStaggerDelay
                    onTriggered: slot.entered = true
                }

                StyledRect {
                    anchors.fill: parent

                    radius: root.pillRounding
                    scale: slot.pressed ? Appearance.bar.workspacePressScale : slot.containsMouse ? Appearance.bar.workspaceHoverScale : 1

                    color: {
                        if (slot.urgent)
                            return Colours.critical;
                        if (slot.active)
                            return Colours.accent;
                        if (slot.occupied)
                            return Colours.accentMuted;
                        return Colours.trough;
                    }

                    Behavior on scale {
                        Anim {
                            type: AnimType.defaultEffects
                        }
                    }
                }
            }
        }
    }
}
