import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property string value
    property bool canDecrease: true
    property bool canIncrease: true
    property int stepperWidth: Appearance.display.stepperWidth

    signal stepped(int delta)

    spacing: 0

    IconButton {
        icon: Icons.minus
        disabled: !root.canDecrease

        onTriggered: root.stepped(-1)
    }

    StyledText {
        Layout.preferredWidth: root.stepperWidth

        text: root.value
        color: Colours.textBright
        horizontalAlignment: Text.AlignHCenter
    }

    IconButton {
        icon: Icons.plus
        disabled: !root.canIncrease

        onTriggered: root.stepped(1)
    }
}
