import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    Layout.rightMargin: Appearance.bar.pillMarginRight

    interactive: true

    onClicked: ControlState.togglePanel()

    Icon {
        text: Icons.notifNormal
    }

    StyledText {
        visible: NotifHistory.unread > 0

        text: NotifHistory.unread
    }
}
