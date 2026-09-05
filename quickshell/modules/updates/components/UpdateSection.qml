pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property string glyph
    required property string title
    required property string placeholder
    required property var entries

    readonly property real contentHeight: Appearance.updates.sectionPaddingV * 2 + header.height + Appearance.updates.listSpacing + list.implicitHeight

    color: Colours.pill
    radius: Appearance.updates.sectionRounding

    RowLayout {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.updates.rowPaddingH
        anchors.rightMargin: Appearance.updates.rowPaddingH
        anchors.topMargin: Appearance.updates.sectionPaddingV

        height: Appearance.updates.sectionHeaderHeight
        spacing: Appearance.updates.sectionHeaderSpacing

        Icon {
            text: root.glyph
            color: Colours.textBright
            font.pixelSize: Appearance.updates.sectionIconSize
        }

        StyledText {
            Layout.fillWidth: true

            text: root.title
            color: Colours.textBright
            font.weight: Appearance.font.weightActive
            elide: Text.ElideRight
        }

        StyledText {
            text: root.entries.length
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }
    }

    StyledText {
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.leftMargin: Appearance.updates.rowPaddingH
        anchors.topMargin: Appearance.updates.listSpacing

        visible: root.entries.length === 0
        text: root.placeholder
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    Flickable {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.updates.listSpacing
        anchors.bottomMargin: Appearance.updates.sectionPaddingV

        visible: root.entries.length > 0
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list

            width: parent.width

            spacing: Appearance.updates.listSpacing

            Repeater {
                model: root.entries

                UpdateRow {
                    required property var modelData

                    Layout.fillWidth: true

                    entry: modelData
                }
            }
        }
    }
}
