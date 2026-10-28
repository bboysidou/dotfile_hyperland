import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.updates
import qs.services

Pill {
    id: root

    leading: Appearance.bar.updatesMarginLeft
    trailing: Appearance.bar.updatesMarginRight

    visible: Updates.available
    interactive: true

    onClicked: UpdatesState.toggle()

    Icon {
        text: Icons.updates
        color: Colours.accent
    }

    StyledText {
        text: Updates.count
        color: Colours.accent
    }
}
