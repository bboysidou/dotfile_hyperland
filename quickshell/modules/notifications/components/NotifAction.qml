pragma ComponentBehavior: Bound

import qs.core.components
import qs.core.config
import qs.services

Pill {
    id: root

    property Notif popup
    required property var action

    color: hovered ? Colours.hover : Colours.trough
    paddingV: Appearance.notif.actionPaddingV
    paddingH: Appearance.notif.actionPaddingH
    interactive: true

    visible: !!root.action

    onClicked: root.popup ? root.popup.invoke(root.action) : root.action.invoke()

    StyledText {
        text: root.action?.text ?? ""
        color: Colours.textBright
        font.pixelSize: Appearance.font.size.small
    }
}
