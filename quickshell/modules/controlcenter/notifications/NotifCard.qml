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
    property int position: 0
    property bool expanded: true
    property bool entered: false

    readonly property bool critical: root.group.entries.some(entry => entry.critical)
    readonly property bool unread: root.group.entries.some(entry => !entry.read)

    implicitHeight: header.height + wrapper.height

    color: root.expanded ? Colours.elevated : Colours.pill
    radius: Appearance.notifPanel.cardRounding
    border.width: root.activeFocus ? Appearance.card.activeBorderWidth : Appearance.notifPanel.cardBorderWidth
    border.color: root.critical ? Colours.urgencyCritical : (root.activeFocus ? Colours.accent : Colours.border)

    activeFocusOnTab: true
    opacity: root.entered ? 1 : 0

    onVisibleChanged: {
        if (!root.visible)
            root.entered = false;
    }

    Keys.onReturnPressed: root.expanded = !root.expanded
    Keys.onSpacePressed: root.expanded = !root.expanded
    Keys.onDeletePressed: NotifHistory.clearApp(root.group.appName)

    transform: Translate {
        y: root.entered ? 0 : Appearance.card.lift

        Behavior on y {
            NumberAnimation {
                duration: Appearance.card.enterDuration
                easing.type: Easing.OutQuint
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.card.enterDuration
            easing.type: Easing.OutQuint
        }
    }

    Timer {
        running: root.visible
        interval: Appearance.card.staggerBase + root.position * Appearance.card.staggerStep

        onTriggered: root.entered = true
    }

    StyledRect {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: Appearance.notifPanel.cardHeaderHeight
        radius: parent.radius
        color: "transparent"

        StateLayer {
            id: headerPointer

            radius: parent.radius

            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.notifPanel.cardPaddingH
            anchors.rightMargin: Appearance.notifPanel.cardPaddingH

            spacing: Appearance.notifPanel.cardSpacing

            Item {
                Layout.preferredWidth: Appearance.notifPanel.cardIconSize
                Layout.preferredHeight: Appearance.notifPanel.cardIconSize

                IconImage {
                    anchors.fill: parent

                    visible: root.group.image.length > 0
                    source: root.group.image
                }

                Icon {
                    anchors.centerIn: parent

                    visible: root.group.image.length === 0
                    text: root.critical ? Icons.notifCritical : Icons.notifNormal
                    color: root.critical ? Colours.urgencyCritical : Colours.textMuted
                    font.pixelSize: Appearance.notifPanel.cardIconSize
                }
            }

            StyledRect {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Appearance.notifPanel.dotSize
                Layout.preferredHeight: Appearance.notifPanel.dotSize

                visible: root.unread
                radius: Appearance.rounding.full
                color: Colours.textBright
            }

            StyledText {
                Layout.fillWidth: true

                text: root.group.appName
                color: Colours.textBright
                font.pixelSize: Appearance.notifPanel.cardNameSize
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
        height: root.expanded ? body.implicitHeight + Appearance.notifPanel.cardPaddingV * 2 : 0

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
            anchors.bottomMargin: Appearance.notifPanel.cardPaddingV
            anchors.leftMargin: Appearance.notifPanel.cardPaddingH
            anchors.rightMargin: Appearance.notifPanel.cardPaddingH

            visible: wrapper.height > 0
            spacing: Appearance.notifPanel.cardSpacing

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
