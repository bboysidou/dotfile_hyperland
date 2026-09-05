import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    Layout.rightMargin: Appearance.bar.pillMarginRight

    visible: Net.available
    interactive: true

    onClicked: ControlState.toggle(ControlSection.network)

    Icon {
        text: Net.glyph
    }
}
