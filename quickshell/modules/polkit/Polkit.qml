pragma ComponentBehavior: Bound

import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.modules.polkit.components

Scope {
    id: root

    property string buffer: ""

    readonly property AuthFlow flow: agent.flow

    function reset(): void {
        root.buffer = "";
    }

    function submit(): void {
        if (!root.flow?.isResponseRequired || !root.buffer)
            return;

        root.flow.submit(root.buffer);
        root.buffer = "";
    }

    function cancel(): void {
        root.flow?.cancelAuthenticationRequest();
        root.buffer = "";
    }

    PolkitAgent {
        id: agent

        onFlowChanged: root.reset()
    }

    Variants {
        model: Quickshell.screens

        FocusedPanel {
            id: panel

            shown: root.flow !== null && !root.flow.isCompleted

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            implicitWidth: Appearance.polkit.width
            implicitHeight: layout.implicitHeight + Appearance.polkit.padding * 2

            mask: Region {
                item: card
            }

            onVisibleChanged: {
                if (panel.visible)
                    keys.forceActiveFocus();
            }

            RevealCard {
                id: card

                anchors.fill: parent

                radius: Appearance.polkit.rounding
                border.width: Appearance.polkit.borderWidth

                revealed: panel.visible
                scaleFrom: Appearance.polkit.scaleFrom

                ColumnLayout {
                    id: layout

                    anchors.fill: parent
                    anchors.margins: Appearance.polkit.padding

                    spacing: Appearance.polkit.spacing

                    Prompt {
                        Layout.fillWidth: true

                        flow: root.flow
                        buffer: root.buffer
                    }

                    Actions {
                        Layout.fillWidth: true

                        onConfirmed: root.submit()
                        onCancelled: root.cancel()
                    }
                }

                KeyBuffer {
                    id: keys

                    onAccepted: root.submit()
                    onCancelled: root.cancel()
                    onBackspaced: root.buffer = root.buffer.slice(0, -1)
                    onAppended: text => root.buffer += text
                }
            }
        }
    }
}
