pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.modules.border
import qs.modules.notifications.components
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        FocusedPanel {
            id: panel

            shown: Notifs.stack.length > 0 && BorderState.rightInset === 0

            exclusiveZone: 0
            WlrLayershell.keyboardFocus: Notifs.replyTarget ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            implicitWidth: Math.max(1, stack.implicitWidth + Appearance.border.fillet)
            implicitHeight: Math.max(1, stack.implicitHeight + Appearance.border.fillet)

            anchors {
                top: true
                right: true
            }

            mask: Region {
                item: stack
            }

            StyledRect {
                id: stack

                anchors.top: parent.top
                anchors.right: parent.right

                readonly property real presence: Math.min(1, column.implicitHeight / Appearance.border.fillet)

                implicitWidth: column.implicitWidth + Appearance.notif.stackPadding * 2
                implicitHeight: column.implicitHeight + Appearance.notif.stackPadding * 2 * stack.presence

                color: Colours.bar
                topLeftRadius: 0
                topRightRadius: 0
                bottomRightRadius: 0
                bottomLeftRadius: Appearance.border.rounding * stack.presence

                Fillet {
                    anchors.right: parent.left
                    anchors.top: parent.top

                    size: Appearance.border.fillet * stack.presence
                    origin: Corner.bottomLeft
                }

                Fillet {
                    anchors.right: parent.right
                    anchors.top: parent.bottom

                    size: Appearance.border.fillet * stack.presence
                    origin: Corner.bottomLeft
                }

                ColumnLayout {
                    id: column

                    anchors.centerIn: parent

                    spacing: Appearance.notif.stackSpacing

                    Repeater {
                        model: Notifs.stack

                        Toast {}
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "notifications"

        function dismiss(): void {
            Notifs.dismissLatest();
        }

        function dismissAll(): void {
            Notifs.dismissAll();
        }

        function open(): void {
            Notifs.openLatest();
        }

        function restore(): string {
            return Notifs.restore() ? IpcStatus.open : IpcStatus.closed;
        }
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "notif-dismiss"

        onPressed: Notifs.dismissLatest()
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "notif-dismiss-all"

        onPressed: Notifs.dismissAll()
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "notif-open"

        onPressed: Notifs.openLatest()
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "notif-restore"

        onPressed: Notifs.restore()
    }
}
