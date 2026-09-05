pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.core.components
import qs.core.config

Pill {
    id: root

    required property var panel

    Layout.rightMargin: Appearance.bar.pillMarginRight

    visible: SystemTray.items.values.length > 0
    spacing: Appearance.bar.traySpacing

    Repeater {
        model: SystemTray.items

        TrayItem {
            panel: root.panel
        }
    }
}
