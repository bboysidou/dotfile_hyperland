pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

StyledRect {
    id: root

    required property var group

    property bool expanded: true

    implicitHeight: header.height + wrapper.height

    color: "transparent"
    radius: Appearance.notif.cardRounding

    StyledRect {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: Appearance.notif.cardHeaderHeight
        radius: parent.radius
        color: "transparent"

        StateLayer {
            id: headerPointer

            radius: parent.radius

            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.notif.cardPaddingH
            anchors.rightMargin: Appearance.notif.cardPaddingH

            spacing: Appearance.notif.cardSpacing

            Item {
                Layout.preferredWidth: Appearance.notif.cardIconSize
                Layout.preferredHeight: Appearance.notif.cardIconSize

                IconImage {
                    anchors.fill: parent

                    visible: root.group.image.length > 0
                    source: root.group.image
                }

                Icon {
                    anchors.centerIn: parent

                    visible: root.group.image.length === 0
                    text: Icons.notifNormal
                    color: Colours.textMuted
                    font.pixelSize: Appearance.notif.cardIconSize
                }
            }

            StyledText {
                text: root.group.appName
                color: Colours.textBright
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledRect {
                Layout.preferredWidth: count.implicitWidth + Appearance.notif.badgePaddingH * 2
                Layout.preferredHeight: count.implicitHeight

                radius: Appearance.notif.badgeRounding
                color: Colours.trough

                StyledText {
                    id: count

                    anchors.centerIn: parent

                    text: root.group.entries.length
                    color: Colours.textMuted
                    font.pixelSize: Appearance.font.size.small
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: Fmt.relativeTime(root.group.latest)
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }

            Item {
                Layout.preferredWidth: Appearance.notif.clearIconSize
                Layout.preferredHeight: Appearance.notif.clearIconSize

                Icon {
                    anchors.centerIn: parent

                    opacity: headerPointer.containsMouse || clearPointer.containsMouse ? 1 : 0
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
                    id: clearPointer

                    radius: parent.height

                    onClicked: NotifHistory.clearApp(root.group.appName)
                }
            }

            Icon {
                text: root.expanded ? Icons.sectionExpanded : Icons.sectionCollapsed
                color: Colours.textMuted
            }
        }
    }

    Item {
        id: wrapper

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom

        clip: true
        height: root.expanded ? body.implicitHeight + Appearance.notif.cardSpacing : 0

        Behavior on height {
            Anim {
                type: AnimType.standardSmall
            }
        }

        ColumnLayout {
            id: body

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: wrapper.height > 0
            spacing: Appearance.notif.cardSpacing

            Repeater {
                model: root.group.entries

                NotifRow {
                    required property var modelData

                    entry: modelData
                }
            }
        }
    }
}
