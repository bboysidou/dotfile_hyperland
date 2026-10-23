pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.helpers
import qs.services

Column {
    id: root

    spacing: Appearance.lock.statusSpacing

    Chip {
        glyph: Net.glyph
        label: Net.wiredConnected ? Net.wiredDevice.name : Net.activeNetwork?.name ?? Appearance.lock.emptyNoNetwork
    }

    Chip {
        glyph: Glyphs.bluetooth(Bt.enabled, Bt.connected)
        label: Bt.enabled ? (Bt.connected > 0 ? String(Bt.connected) : Appearance.control.labelBluetooth) : Appearance.lock.emptyNoBluetooth
    }
}
