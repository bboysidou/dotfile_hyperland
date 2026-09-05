pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.modules.osd.components
import qs.services

Scope {
    id: root

    readonly property bool micMuted: Audio.source?.audio?.muted ?? false
    readonly property int micPercent: Math.round((Audio.source?.audio?.volume ?? 0) * Appearance.audio.max)

    Variants {
        model: Quickshell.screens

        FocusedPanel {
            id: panel

            shown: Osd.visible

            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors.right: true

            margins.right: ControlState.opened ? Appearance.control.width : 0

            implicitWidth: Math.max(1, card.implicitWidth)
            implicitHeight: Math.max(1, card.implicitHeight + Appearance.border.fillet * 2)

            mask: Region {}

            RevealCard {
                id: card

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                implicitWidth: row.implicitWidth + Appearance.osd.padding * 2
                implicitHeight: row.implicitHeight + Appearance.osd.padding * 2

                color: Colours.bar
                border.width: 0
                topLeftRadius: Appearance.border.rounding
                bottomLeftRadius: Appearance.border.rounding
                topRightRadius: 0
                bottomRightRadius: 0

                revealed: panel.visible
                scaleFrom: Appearance.osd.scaleFrom
                transformOrigin: Item.Right

                Fillet {
                    anchors.right: parent.right
                    anchors.bottom: parent.top

                    origin: Corner.topLeft
                }

                Fillet {
                    anchors.right: parent.right
                    anchors.top: parent.bottom

                    origin: Corner.bottomLeft
                }

                ColumnLayout {
                    id: row

                    anchors.centerIn: parent

                    spacing: Appearance.osd.padding

                    OsdMeter {
                        glyph: Glyphs.volume(Audio.percent, Audio.muted)
                        percent: Audio.percent
                        muted: Audio.muted
                        active: Osd.kind === OsdKind.volume
                    }

                    OsdMeter {
                        glyph: root.micMuted ? Icons.microphoneMuted : Icons.microphone
                        percent: root.micPercent
                        muted: root.micMuted
                        active: Osd.kind === OsdKind.microphone
                    }

                    OsdMeter {
                        visible: Brightness.available

                        glyph: Icons.brightness
                        percent: Brightness.percent
                        muted: false
                        active: Osd.kind === OsdKind.brightness
                    }
                }
            }
        }
    }
}
