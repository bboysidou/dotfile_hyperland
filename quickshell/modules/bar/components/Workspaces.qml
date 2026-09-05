pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.core.components
import qs.core.config
import qs.core.enums

RowLayout {
    id: root

    readonly property var slotIds: {
        const ids = Hyprland.workspaces.values.map(ws => ws.id).filter(id => id > 0);

        for (let id = 1; id <= Appearance.bar.workspacesMinimum; id++)
            if (!ids.includes(id))
                ids.push(id);

        return ids.sort((a, b) => a - b);
    }

    function activate(id: int): void {
        Hyprland.dispatch(Hyprland.usingLua ? `hl.dsp.focus({ workspace = ${id} })` : `workspace ${id}`);
    }

    spacing: Appearance.spacing.none

    Repeater {
        model: root.slotIds

        MouseArea {
            id: slot

            required property int modelData

            readonly property int workspaceId: modelData
            readonly property var workspace: Hyprland.workspaces.values.find(ws => ws.id === workspaceId) ?? null
            readonly property bool occupied: (workspace?.lastIpcObject?.windows ?? 0) > 0
            readonly property bool active: Hyprland.focusedWorkspace?.id === workspaceId
            readonly property bool urgent: workspace?.urgent ?? false

            Layout.leftMargin: Appearance.bar.workspaceMarginLeft
            Layout.topMargin: Appearance.bar.workspaceMarginV
            Layout.bottomMargin: Appearance.bar.workspaceMarginV

            implicitWidth: Appearance.bar.workspaceDotSize + Appearance.bar.workspacePadding * 2
            implicitHeight: glyph.implicitHeight + Appearance.bar.workspacePadding * 2

            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: root.activate(slot.workspaceId)

            Icon {
                id: glyph

                anchors.centerIn: parent

                text: slot.active ? Icons.workspaceActive : Icons.workspaceDefault
                font.pixelSize: Appearance.bar.workspaceFontSize
                opacity: slot.containsMouse ? Appearance.bar.workspaceHoverOpacity : 1

                color: {
                    if (slot.urgent)
                        return Colours.critical;
                    if (slot.containsMouse)
                        return Colours.textBright;
                    if (slot.active || slot.occupied)
                        return Colours.highlight;
                    return Colours.textMuted;
                }

                Behavior on color {
                    CAnim {
                        type: AnimType.fastEffects
                    }
                }
            }
        }
    }
}
