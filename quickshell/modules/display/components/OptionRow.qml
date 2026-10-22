import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property string label

    default property alias content: slot.data

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.display.rowHeight

    spacing: Appearance.display.gridSpacing

    StyledText {
        Layout.preferredWidth: Appearance.display.labelWidth

        text: root.label
        color: Colours.textMuted
    }

    Flow {
        id: slot

        Layout.fillWidth: true

        spacing: Appearance.display.chipSpacing
    }
}
