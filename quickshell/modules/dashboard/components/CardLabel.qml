import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property string icon: ""
    property string label: ""
    property color colour: Colours.accent

    spacing: Appearance.dash.cardSpacing

    Icon {
        text: root.icon
        color: root.colour
        font.pixelSize: Appearance.dash.cardLabelSize
    }

    StyledText {
        Layout.fillWidth: true

        text: root.label
        color: Colours.textMuted
        opacity: Appearance.dash.cardLabelOpacity
        font.pixelSize: Appearance.dash.cardLabelSize
        elide: Text.ElideRight
    }
}
