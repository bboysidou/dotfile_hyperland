pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.core.enums
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

            exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors.top: true

            implicitWidth: Appearance.polkit.width + Appearance.border.fillet * 2
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

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                width: Appearance.polkit.width

                color: Colours.bar
                topLeftRadius: 0
                topRightRadius: 0
                bottomLeftRadius: Appearance.border.rounding
                bottomRightRadius: Appearance.border.rounding

                revealed: panel.visible
                elevation: 0
                scaleFrom: Appearance.polkit.scaleFrom
                transformOrigin: Item.Top

                Fillet {
                    anchors.right: parent.left
                    anchors.top: parent.top

                    origin: Corner.bottomLeft
                }

                Fillet {
                    anchors.left: parent.right
                    anchors.top: parent.top

                    origin: Corner.bottomRight
                }

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
                    onCleared: root.buffer = ""
                    onAppended: text => root.buffer += text
                }
            }
        }
    }
}
