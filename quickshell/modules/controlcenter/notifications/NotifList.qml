pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

Item {
    id: root

    RowLayout {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: Appearance.notif.headerHeight
        spacing: Appearance.notif.cardSpacing

        StyledText {
            text: Appearance.notif.labelNotifications
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        StyledText {
            text: NotifHistory.entries.length
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            visible: NotifHistory.entries.length > 0

            text: Appearance.notif.labelClearAll
            color: clearPointer.containsMouse ? Colours.textBright : Colours.textMuted
            font.pixelSize: Appearance.font.size.small

            StateLayer {
                id: clearPointer

                radius: parent.height

                onClicked: NotifHistory.clear()
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent

        visible: NotifHistory.entries.length === 0
        glyph: Icons.notifNormal
        title: Appearance.notif.emptyTitle
        subtitle: Appearance.notif.emptySubtitle
    }

    Flickable {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.notif.listSpacing

        visible: NotifHistory.entries.length > 0
        contentHeight: cards.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: cards

            width: parent.width

            spacing: Appearance.notif.listSpacing

            Repeater {
                model: NotifHistory.groups

                NotifCard {
                    required property var modelData

                    Layout.fillWidth: true

                    group: modelData
                }
            }
        }
    }
}
