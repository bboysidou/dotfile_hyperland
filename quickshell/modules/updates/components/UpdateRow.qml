import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property var entry

    implicitHeight: Appearance.updates.rowHeight

    color: "transparent"
    radius: Appearance.updates.rowRounding

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
            Layout.maximumWidth: Appearance.updates.versionMaxWidth

            text: root.entry.from
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        StyledText {
            text: Appearance.updates.versionArrow
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        ScrollText {
            Layout.maximumWidth: Appearance.updates.versionMaxWidth

            text: root.entry.to
            color: Colours.accent
            font.pixelSize: Appearance.font.size.small
        }
    }
}
