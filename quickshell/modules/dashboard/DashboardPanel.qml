pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.dashboard.components
import qs.modules.dashboard.dash
import qs.modules.dashboard.media
import qs.modules.dashboard.performance

RevealCard {
    id: root

    readonly property Item pane: repeater.count > DashState.index ? repeater.itemAt(DashState.index) : null
    readonly property real paneWidth: root.pane?.implicitWidth ?? 0
    readonly property real paneHeight: root.pane?.implicitHeight ?? 0

    implicitWidth: root.paneWidth + Appearance.dash.padding * 2
    implicitHeight: (tabs.implicitHeight || 0) + root.paneHeight + Appearance.dash.padding * 3

    color: Colours.bar
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: Appearance.border.rounding
    bottomRightRadius: Appearance.border.rounding
    scaleFrom: Appearance.dash.scaleFrom
    transformOrigin: Item.Top

    visible: root.revealed || root.opacity > 0
    focus: true

    Keys.onPressed: event => {
        const tabs = Nav.horizontal(event);
        if (tabs !== 0) {
            DashState.step(tabs);
            event.accepted = true;
        }
    }

    onRevealedChanged: {
        if (root.revealed && DashState.pinned)
            root.forceActiveFocus();
    }

    Behavior on implicitWidth {
        Anim {
            type: AnimType.emphasizedSmall
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: AnimType.emphasizedSmall
        }
    }

    readonly property bool onDash: DashState.tab === DashSection.dash
    readonly property bool onMedia: DashState.tab === DashSection.media

    HoverHandler {
        onHoveredChanged: DashState.panelHover = hovered
    }

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

    TabStrip {
        id: tabs

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.dash.padding

        current: DashState.tab
        tabs: [
            {
                section: DashSection.dash,
                icon: Icons.dashTab,
                label: Appearance.dash.labelDash
            },
            {
                section: DashSection.performance,
                icon: Icons.perfTab,
                label: Appearance.dash.labelPerformance
            },
            {
                section: DashSection.media,
                icon: Icons.mediaTab,
                label: Appearance.dash.labelMedia
            }
        ]

        onSelected: section => DashState.tab = section
    }

    ClippingRectangle {
        id: viewport

        anchors.top: tabs.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.dash.padding

        width: root.paneWidth
        height: root.paneHeight
        color: "transparent"
        radius: Appearance.dash.cardRounding

        Row {
            id: row

            spacing: Appearance.dash.padding * 2
            x: -(root.pane?.x ?? 0)

            Behavior on x {
                Anim {
                    type: AnimType.emphasized
                }
            }

            Repeater {
                id: repeater

                model: DashState.sections

                DelegateChooser {
                    role: "modelData"

                    DelegateChoice {
                        roleValue: DashSection.dash

                        delegate: DashPane {
                            active: root.onDash
                        }
                    }
                    DelegateChoice {
                        roleValue: DashSection.performance

                        delegate: PerfPane {}
                    }
                    DelegateChoice {
                        roleValue: DashSection.media

                        delegate: MediaPane {
                            active: root.onMedia
                        }
                    }
                }
            }
        }
    }
}
