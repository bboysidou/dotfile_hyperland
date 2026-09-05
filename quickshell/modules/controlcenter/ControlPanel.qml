pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models
import QtQuick.Window
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter.notifications
import qs.modules.controlcenter.panes
import qs.services

RevealCard {
    id: root

    readonly property int index: ControlSection.values.indexOf(ControlState.section)
    readonly property Item pane: root.index >= 0 && repeater.count > root.index ? repeater.itemAt(root.index) : null
    readonly property real paneHeight: Math.min(root.pane?.implicitHeight ?? 0, root.height * Appearance.control.topPaneMaxRatio)

    function step(delta: int): void {
        const values = ControlSection.values;
        ControlState.section = values[Num.wrap(root.index, delta, values.length)];
    }

    function focusStep(forward: bool): void {
        const current = root.Window.activeFocusItem ?? root;
        const next = current.nextItemInFocusChain(forward);
        if (next)
            next.forceActiveFocus();
    }

    function dismissPrompt(): void {
        const at = ControlSection.values.indexOf(ControlSection.network);
        repeater.itemAt(at)?.dismiss();
    }

    implicitWidth: Appearance.control.width

    color: Colours.bar
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: Appearance.control.scaleFrom
    transformOrigin: Item.TopRight

    visible: root.revealed || root.opacity > 0
    focus: true

    onRevealedChanged: {
        if (root.revealed) {
            NotifHistory.markAllRead();
            root.forceActiveFocus();
        } else {
            root.dismissPrompt();
        }
    }

    Keys.onPressed: event => {
        const sections = Nav.horizontal(event);
        const focus = Nav.vertical(event);

        if (sections !== 0) {
            root.step(sections);
            event.accepted = true;
        } else if (focus !== 0) {
            root.focusStep(focus > 0);
            event.accepted = true;
        }
    }

    Fillet {
        anchors.right: parent.left
        anchors.top: parent.top

        origin: Corner.bottomLeft
    }

    Fillet {
        anchors.right: parent.left
        anchors.bottom: parent.bottom

        origin: Corner.topLeft
    }

    TabStrip {
        id: tabs

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.control.tabStripMargin

        current: ControlState.section
        tabs: [
            {
                section: ControlSection.audio,
                icon: Icons.speaker,
                label: Appearance.control.labelAudio
            },
            {
                section: ControlSection.network,
                icon: Net.glyph,
                label: Appearance.control.labelNetwork
            },
            {
                section: ControlSection.bluetooth,
                icon: Icons.bluetooth,
                label: Appearance.control.labelBluetooth
            }
        ]

        onSelected: section => ControlState.section = section
    }

    ClippingRectangle {
        id: viewport

        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.control.padding
        anchors.leftMargin: Appearance.control.padding
        anchors.rightMargin: Appearance.control.padding

        height: root.paneHeight
        color: "transparent"

        Behavior on height {
            Anim {
                type: AnimType.emphasizedSmall
            }
        }

        Row {
            id: row

            x: -(root.pane?.x ?? 0)

            Behavior on x {
                Anim {
                    type: AnimType.emphasized
                }
            }

            Repeater {
                id: repeater

                model: ControlSection.values

                DelegateChooser {
                    role: "modelData"

                    DelegateChoice {
                        roleValue: ControlSection.audio

                        delegate: AudioPane {
                            width: viewport.width
                            height: viewport.height
                        }
                    }
                    DelegateChoice {
                        roleValue: ControlSection.network

                        delegate: NetworkPane {
                            width: viewport.width
                            height: viewport.height

                            onCloseRequested: ControlState.hide()
                        }
                    }
                    DelegateChoice {
                        roleValue: ControlSection.bluetooth

                        delegate: BluetoothPane {
                            width: viewport.width
                            height: viewport.height
                        }
                    }
                }
            }
        }
    }

    NotifList {
        anchors.top: viewport.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Appearance.control.padding
    }

    Binding {
        target: Net
        property: "scanning"
        value: ControlState.opened && ControlState.section === ControlSection.network
    }

    Binding {
        target: NotifHistory
        property: "viewing"
        value: ControlState.opened
    }
}
