import QtQuick
import qs.core.components
import qs.core.config

Icon {
    id: root

    property string icon: ""
    property int size: Appearance.dash.iconButtonSize
    property bool active: false
    property bool accent: false
    property bool disabled: false

    signal triggered

    text: root.icon
    font.pixelSize: root.size

    color: {
        if (root.disabled)
            return Colours.textMuted;
        if (root.accent || root.active)
            return Colours.accent;
        return Colours.text;
    }

    StateLayer {
        radius: parent.height / 2
        disabled: root.disabled

        onClicked: root.triggered()
    }
}
