import QtQuick
import qs.core.components
import qs.core.config

IconButton {
    id: root

    required property Item panel
    required property string screenName

    x: root.panel.x + root.panel.width - root.width - Appearance.border.pinInset
    y: root.panel.y + Appearance.border.pinInset
    z: 2

    opacity: root.panel.opacity
    visible: root.panel.revealed

    icon: BorderState.pinned ? Icons.pin : Icons.pinOutline
    size: Appearance.border.pinSize
    active: BorderState.pinned

    onTriggered: BorderState.togglePin(root.screenName)
}
