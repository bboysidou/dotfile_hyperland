import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

StyledRect {
    id: root

    required property var node
    property bool selected: false
    property bool fallback: false
    property color accent: Colours.audioStream

    signal picked

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.audioPanel.routeOptionHeight

    radius: Appearance.audioPanel.routeRounding
    color: "transparent"

    StateLayer {
        disabled: root.selected
        radius: root.radius

        onClicked: root.picked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.audioPanel.routePaddingH
        anchors.rightMargin: Appearance.audioPanel.routePaddingH

        spacing: Appearance.card.spacing

        Icon {
            text: Icons.check
            color: root.accent
            opacity: root.selected ? 1 : 0
            font.pixelSize: Appearance.audioPanel.routeIconSize
        }

        ScrollText {
            Layout.fillWidth: true

            text: Audio.label(root.node)
            color: root.selected ? Colours.textBright : Colours.textMuted
            font.pixelSize: Appearance.audioPanel.routeTextSize
        }

        StyledText {
            visible: root.fallback
            text: Appearance.audioPanel.labelDefaultSink
            color: Colours.textMuted
            font.pixelSize: Appearance.audioPanel.routeTextSize
        }
    }
}
