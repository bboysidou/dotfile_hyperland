pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.notifications.components
import qs.services

StyledRect {
    id: root

    required property NotifEntry entry

    Layout.fillWidth: true
    Layout.preferredHeight: layout.implicitHeight + Appearance.notif.rowPaddingV * 2

    color: root.entry.critical ? Colours.criticalSurface : Colours.pill
    radius: Appearance.notif.rowRounding

    StateLayer {
        id: pointer

        radius: parent.radius
        cursorShape: root.entry.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: root.entry.defaultAction?.invoke()
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Appearance.notif.rowPaddingH
        anchors.rightMargin: Appearance.notif.rowPaddingH

        spacing: Appearance.notif.rowSpacing

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.notif.rowSpacing

            StyledText {
                Layout.fillWidth: true

                text: root.entry.summary
                color: root.entry.critical ? Colours.urgencyCritical : root.entry.read ? Colours.text : Colours.textBright
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledText {
                text: Fmt.relativeTime(root.entry.time)
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }

            Item {
                Layout.preferredWidth: Appearance.notif.clearIconSize
                Layout.preferredHeight: Appearance.notif.clearIconSize

                Icon {
                    anchors.centerIn: parent

                    opacity: pointer.containsMouse || dismissPointer.containsMouse ? 1 : 0
                    text: Icons.close
                    color: Colours.textMuted
                    font.pixelSize: Appearance.notif.clearIconSize

                    Behavior on opacity {
                        Anim {
                            type: AnimType.defaultEffects
                        }
                    }
                }

                StateLayer {
                    id: dismissPointer

                    radius: parent.height

                    onClicked: NotifHistory.dismiss(root.entry)
                }
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.entry.body.length > 0
            text: root.entry.body
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WordWrap
            maximumLineCount: Appearance.notif.bodyMaxLines
            elide: Text.ElideRight
        }

        RowLayout {
            visible: root.entry.buttons.length > 0

            spacing: Appearance.notif.actionSpacing

            Repeater {
                model: root.entry.buttons

                NotifAction {
                    required property var modelData

                    action: modelData
                }
            }
        }
    }
}
