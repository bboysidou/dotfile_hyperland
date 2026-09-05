import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

RowLayout {
    id: root

    required property NotifEntry entry

    spacing: Appearance.dash.cardSpacing

    StyledText {
        Layout.fillWidth: true

        text: Str.oneLine(root.entry.summary)
        color: root.entry.critical ? Colours.urgencyCritical : root.entry.read ? Colours.text : Colours.textBright
        font.pixelSize: Appearance.dash.cardLabelSize
        elide: Text.ElideRight
    }

    StyledText {
        text: Fmt.relativeTime(root.entry.time)
        color: Colours.textMuted
        font.pixelSize: Appearance.dash.cardLabelSize
    }
}
