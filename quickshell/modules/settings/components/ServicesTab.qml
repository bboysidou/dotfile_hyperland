pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    readonly property var config: Appearance.settings

    spacing: root.config.listSpacing

    StyledText {
        Layout.fillWidth: true

        text: root.config.hintServices
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
        wrapMode: Text.WordWrap
    }

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true

        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list

            width: parent.width

            spacing: root.config.listSpacing

            Repeater {
                model: root.config.services

                ServiceCard {
                    required property var modelData

                    entry: modelData
                }
            }
        }
    }
}
