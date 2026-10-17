pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.services

Item {
    id: root

    implicitHeight: chip.implicitHeight

    ChipPackage {
        id: chip

        anchors.centerIn: parent

        width: chip.implicitWidth
        height: chip.implicitHeight
        contentWidth: grid.implicitWidth
        contentHeight: grid.implicitHeight

        Grid {
            id: grid

            anchors.centerIn: parent

            columns: Appearance.hardware.cpuColumns
            spacing: Appearance.hardware.cellSpacing

            Repeater {
                model: CpuStats.coreCount

                CoreCell {
                    required property int index

                    load: CpuStats.cores[index] ?? 0
                }
            }
        }
    }
}
