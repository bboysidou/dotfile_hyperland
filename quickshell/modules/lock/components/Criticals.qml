pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.modules.notifications.components
import qs.services

ColumnLayout {
    id: root

    spacing: Appearance.notif.stackSpacing

    Repeater {
        model: Notifs.criticals

        Toast {
            interactive: false
        }
    }
}
