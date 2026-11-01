import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

RowLayout {
    id: root

    required property Notif popup

    spacing: Appearance.notif.actionSpacing

    TextField {
        id: field

        Layout.fillWidth: true

        placeholder: root.popup.notification?.inlineReplyPlaceholder || Appearance.notif.replyPlaceholder
        placeholderSize: Appearance.font.size.small

        onAccepted: root.popup.reply(field.text)
        onCancelled: root.popup.stopReply()
    }

    NotifChip {
        label: Appearance.notif.labelSend
        accent: true

        onClicked: root.popup.reply(field.text)
    }

    Timer {
        interval: Appearance.anim.durations.small
        running: root.visible

        onTriggered: field.focusInput()
    }
}
