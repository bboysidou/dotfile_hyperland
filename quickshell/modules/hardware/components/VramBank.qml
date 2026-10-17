pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config

Column {
    id: root

    property int bank: 0
    property int used: 0

    readonly property int banks: Appearance.hardware.gpuBanks
    readonly property int halves: Appearance.hardware.chipHalves

    function slot(chip: int, half: int): int {
        return (chip * root.halves + half) * root.banks + root.bank;
    }

    spacing: Appearance.hardware.gpuChipSpacing

    Repeater {
        model: Appearance.hardware.gpuChipsPerSide

        VramChip {
            required property int index

            upperUsed: root.slot(index, 0) < root.used
            lowerUsed: root.slot(index, 1) < root.used
        }
    }
}
