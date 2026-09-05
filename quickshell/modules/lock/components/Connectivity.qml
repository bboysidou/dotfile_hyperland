pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.helpers
import qs.services

Column {
    id: root

    spacing: Appearance.lock.statusSpacing

    Chip {
        glyph: Net.wifiDevice?.connected ? Glyphs.wifi(Net.signalPercent(Net.activeNetwork)) : Net.wiredDevice?.connected ? Icons.ethernet : Icons.wifiOff
        label: Net.activeNetwork?.name ?? (Net.wiredDevice?.connected ? Net.wiredDevice.name : Appearance.lock.emptyNoNetwork)
    }

    Chip {
        glyph: Glyphs.bluetooth(Bt.enabled, Bt.connected)
        label: Bt.enabled ? (Bt.connected > 0 ? String(Bt.connected) : Appearance.control.labelBluetooth) : Appearance.lock.emptyNoBluetooth
    }
}
