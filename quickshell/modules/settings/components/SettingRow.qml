import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    required property string label

    default property alias content: slot.data

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.settings.rowHeight

    spacing: Appearance.settings.cardSpacing

    StyledText {
        Layout.fillWidth: true

        text: root.label
        color: Colours.text
        elide: Text.ElideRight
    }

    Row {
        id: slot

        Layout.alignment: Qt.AlignVCenter

        spacing: Appearance.settings.pickSpacing
    }
}
