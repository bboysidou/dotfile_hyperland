import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

RowLayout {
    id: root

    required property Notif popup
    required property bool aged
    required property string copyText
    property bool interactive: true

    spacing: Appearance.spacing.small

    ScrollText {
        Layout.fillWidth: true

        text: root.popup.summary
        color: root.popup.critical ? Colours.urgencyCritical : Colours.textBright
        font.weight: Appearance.font.weightActive
    }

    StyledText {
        visible: root.popup.origin !== ""

        text: root.popup.origin
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.tiny
    }

    StyledText {
        visible: root.aged

        text: Fmt.age(root.popup.created, Time.now)
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.tiny
        font.weight: Appearance.font.weightIcon
    }

    IconButton {
        visible: root.interactive
        icon: Notifs.copied !== "" && Notifs.copied === root.copyText ? Icons.check : Icons.copy
        size: Appearance.notif.toolSize

        onTriggered: Notifs.copy(root.copyText)
    }
}
