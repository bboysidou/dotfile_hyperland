import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    Layout.rightMargin: Appearance.bar.pillMarginRight

    interactive: true

    onClicked: ControlState.toggle(ControlSection.notifications)

    Icon {
        text: Icons.notifNormal
    }

    StyledText {
        visible: NotifHistory.unread > 0

        text: NotifHistory.unread
    }
}
