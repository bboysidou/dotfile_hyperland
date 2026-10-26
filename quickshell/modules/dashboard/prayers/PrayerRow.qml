import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    required property var entry
    required property bool active
    required property bool elapsed
    required property bool marker
    property color accent: Colours.accent

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.prayer.rowHeight

    spacing: Appearance.dash.cardSpacing

    ScrollText {
        Layout.fillWidth: true

        text: root.entry.label
        color: root.active ? Colours.textBright : root.elapsed || root.marker ? Colours.textMuted : Colours.text
        font.weight: root.active ? Appearance.font.weightActive : Appearance.font.weightNormal
        font.pixelSize: root.marker ? Appearance.dash.cardLabelSize : Appearance.font.size.normal
    }

    StyledText {
        text: root.entry.time
        color: root.active ? root.accent : root.elapsed || root.marker ? Colours.textMuted : Colours.text
        font.weight: root.active ? Appearance.font.weightActive : Appearance.font.weightNormal
        font.pixelSize: root.marker ? Appearance.dash.cardLabelSize : Appearance.font.size.normal
    }
}
