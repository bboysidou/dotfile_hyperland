import QtQuick
import qs.core.components
import qs.core.config

IconButton {
    id: root

    required property Item panel
    required property string screenName
    required property QtObject owner

    readonly property bool held: BorderState.pinnedState === root.owner

    x: root.panel.x + root.panel.width - root.width - Appearance.border.pinInset
    y: root.panel.y + Appearance.border.pinInset
    z: 2

    opacity: root.panel.opacity
    visible: root.panel.revealed

    icon: root.held ? Icons.pin : Icons.pinOutline
    size: Appearance.border.pinSize
    active: root.held

    onTriggered: BorderState.togglePin(root.screenName, root.owner)
}
