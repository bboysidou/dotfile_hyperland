import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.services

Pill {
    id: root

    Layout.leftMargin: Appearance.bar.updatesMarginLeft
    Layout.rightMargin: Appearance.bar.updatesMarginRight

    visible: Updates.available
    interactive: true

    onClicked: Quickshell.execDetached(Commands.updates)

    Icon {
        text: Icons.updates
        color: Colours.accent
    }

    StyledText {
        text: Updates.count
        color: Colours.accent
    }
}
