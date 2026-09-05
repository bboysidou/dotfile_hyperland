pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Polkit
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    required property AuthFlow flow
    required property string buffer

    spacing: Appearance.polkit.spacing

    RowLayout {
        Layout.fillWidth: true

        spacing: Appearance.polkit.spacing

        Icon {
            text: Icons.shield
            color: Colours.accent
            font.pixelSize: Appearance.polkit.iconSize
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Appearance.spacing.none

            StyledText {
                Layout.fillWidth: true

                text: Appearance.polkit.title
                color: Colours.textBright
                font.pixelSize: Appearance.polkit.titleSize
            }

            StyledText {
                Layout.fillWidth: true

                text: root.flow?.message ?? ""
                color: Colours.textMuted
                font.pixelSize: Appearance.polkit.bodySize
                wrapMode: Text.WordWrap
            }
        }
    }

    StyledRect {
        Layout.fillWidth: true

        implicitHeight: Appearance.polkit.fieldHeight

        visible: root.flow?.isResponseRequired ?? false

        color: Colours.trough
        radius: Appearance.polkit.fieldRounding

        StyledText {
            anchors.centerIn: parent

            visible: root.buffer.length === 0
            text: root.flow?.inputPrompt ?? ""
            color: Colours.textMuted
            font.pixelSize: Appearance.polkit.bodySize
        }

        DotField {
            anchors.centerIn: parent

            visible: root.buffer.length > 0
            count: root.buffer.length
            dotSize: Appearance.polkit.dotSize
            dotSpacing: Appearance.polkit.dotSpacing
        }
    }

    StyledText {
        Layout.fillWidth: true

        visible: (root.flow?.supplementaryMessage ?? "").length > 0
        text: root.flow?.supplementaryMessage ?? ""
        color: root.flow?.supplementaryIsError ? Colours.critical : Colours.textMuted
        font.pixelSize: Appearance.polkit.bodySize
        wrapMode: Text.WordWrap
    }
}
