pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.helpers
import qs.services

Column {
    id: root

    spacing: Appearance.lock.statusSpacing

    Chip {
        anchors.right: parent.right

        visible: Battery.available

        glyph: Glyphs.batteryRamp(Battery.percent, Battery.charging)
        label: Appearance.scale.percentTemplate.arg(Battery.percent)
    }

    Chip {
        anchors.right: parent.right

        visible: MouseBattery.available

        glyph: Glyphs.mouse(MouseBattery.charging)
        label: Appearance.scale.percentTemplate.arg(MouseBattery.percent)
    }
}
