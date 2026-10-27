import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property var entry
    required property bool separated

    implicitHeight: Appearance.updates.rowHeight

    color: "transparent"
    radius: Appearance.updates.rowRounding

    StyledRect {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.updates.rowPaddingH
        anchors.rightMargin: Appearance.updates.rowPaddingH

        visible: root.separated
        height: Appearance.updates.separatorHeight
        color: Colours.border
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.updates.rowPaddingH
        anchors.rightMargin: Appearance.updates.rowPaddingH

        spacing: Appearance.updates.rowSpacing

        ScrollText {
            Layout.fillWidth: true

            text: root.entry.name
            color: Colours.text
        }

        ScrollText {
            Layout.preferredWidth: Appearance.updates.versionColumnWidth

            text: root.entry.from
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        ScrollText {
            Layout.preferredWidth: Appearance.updates.versionColumnWidth

            text: root.entry.to
            color: Colours.accent
            font.pixelSize: Appearance.font.size.small
            font.weight: Appearance.font.weightActive
        }
    }
}
