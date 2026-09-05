import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    Layout.rightMargin: Appearance.bar.pillMarginRight

    visible: Bt.available
    interactive: true

    onClicked: ControlState.toggle(ControlSection.bluetooth)

    Icon {
        text: Bt.enabled ? Icons.bluetooth : Icons.bluetoothDisabled
    }

    StyledText {
        visible: Bt.enabled && Bt.connected > 0

        text: Bt.connected
    }
}
