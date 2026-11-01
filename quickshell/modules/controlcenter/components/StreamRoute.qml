pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

ColumnLayout {
    id: root

    required property var node
    property color accent: Colours.audioStream
    property bool open: false

    readonly property var current: Audio.streamOutput(root.node)

    spacing: Appearance.audioPanel.routeSpacing

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: Appearance.audioPanel.routeHeight

        radius: Appearance.audioPanel.routeRounding
        color: Colours.trough
        border.width: Appearance.card.borderWidth
        border.color: Colours.border

        StateLayer {
            radius: parent.radius

            onClicked: root.open = !root.open
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.audioPanel.routePaddingH
            anchors.rightMargin: Appearance.audioPanel.routePaddingH

            spacing: Appearance.card.spacing

            Icon {
                text: Icons.speaker
                color: root.accent
                font.pixelSize: Appearance.audioPanel.routeIconSize
            }

            ScrollText {
                Layout.fillWidth: true

                text: Audio.label(root.current) || Appearance.audioPanel.labelNoDevice
                color: Colours.textBright
                font.pixelSize: Appearance.audioPanel.routeTextSize
            }

            Icon {
                text: root.open ? Icons.chevronUp : Icons.chevronDown
                color: Colours.textMuted
                font.pixelSize: Appearance.audioPanel.routeIconSize
            }
        }
    }

    Repeater {
        model: root.open ? Audio.outputs : []

        StreamRouteOption {
            required property var modelData

            node: modelData
            selected: modelData === root.current
            fallback: modelData === Audio.sink
            accent: root.accent

            onPicked: {
                Audio.routeStream(root.node, modelData);
                root.open = false;
            }
        }
    }
}
