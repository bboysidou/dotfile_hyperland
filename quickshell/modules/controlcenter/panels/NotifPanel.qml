import QtQuick
import qs.core.enums
import qs.modules.controlcenter
import qs.modules.controlcenter.notifications
import qs.services

Panel {
    id: root

    onRevealedChanged: {
        if (root.revealed)
            NotifHistory.markAllRead();
    }

    NotifList {
        anchors.fill: parent
    }

    Binding {
        target: NotifHistory
        property: "viewing"
        value: ControlState.opened && ControlState.section === ControlSection.notifications
    }
}
