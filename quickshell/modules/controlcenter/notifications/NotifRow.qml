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

    readonly property string copyText: [root.entry.summary, Str.plain(root.entry.body)].filter(part => part !== "").join("\n")

    Layout.fillWidth: true
    Layout.preferredHeight: layout.implicitHeight + Appearance.notif.rowPaddingV * 2

    color: root.entry.critical ? Colours.criticalSurface : Colours.pill
    radius: Appearance.notif.rowRounding

    StateLayer {
        id: pointer

        radius: parent.radius
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                NotifHistory.dismiss(root.entry);
            else
                Notifs.activateEntry(root.entry);
        }
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

            ScrollText {
                Layout.fillWidth: true

                text: Str.oneLine(root.entry.summary)
                color: root.entry.critical ? Colours.urgencyCritical : root.entry.read ? Colours.text : Colours.textBright
                font.weight: Appearance.font.weightActive
            }

            StyledText {
                text: root.entry.origin !== "" ? Appearance.notif.originTemplate.arg(root.entry.origin).arg(Fmt.relativeTime(root.entry.time)) : Fmt.relativeTime(root.entry.time)
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }

            IconButton {
                icon: Notifs.copied !== "" && Notifs.copied === root.copyText ? Icons.check : Icons.copy
                size: Appearance.notif.toolSize

                onTriggered: Notifs.copy(root.copyText)
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
            visible: root.entry.buttons.length > 0 || root.entry.code !== ""

            spacing: Appearance.notif.actionSpacing

            NotifChip {
                visible: root.entry.code !== ""
                glyph: Notifs.copied === root.entry.code ? Icons.check : Icons.key
                label: Notifs.copied === root.entry.code ? Appearance.notif.copiedLabel : Appearance.notif.codeTemplate.arg(root.entry.code)
                accent: true

                onClicked: Notifs.copy(root.entry.code)
            }

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
