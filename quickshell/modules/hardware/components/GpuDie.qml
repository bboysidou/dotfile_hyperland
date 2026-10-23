import QtQuick
import qs.core.config
import qs.services

Item {
    id: root

    readonly property int slots: Appearance.hardware.gpuChipsPerSide * Appearance.hardware.gpuBanks * Appearance.hardware.chipHalves
    readonly property int used: Math.round(GpuStats.vramFraction * root.slots)

    implicitHeight: row.implicitHeight

    Row {
        id: row

        anchors.centerIn: parent

        spacing: Appearance.hardware.gpuChipGap

        VramBank {
            anchors.verticalCenter: parent.verticalCenter

            bank: 0
            used: root.used
        }

        ChipPackage {
            anchors.verticalCenter: parent.verticalCenter

            width: implicitWidth
            height: implicitHeight
            pinned: false
            contentWidth: meters.implicitWidth
            contentHeight: meters.implicitHeight

            Row {
                id: meters

                anchors.centerIn: parent

                spacing: Appearance.hardware.gpuColumnSpacing

                GpuMeter {
                    visible: isFinite(GpuStats.busy)
                    glyph: Icons.speedometer
                    value: GpuStats.busy
                }

                GpuMeter {
                    visible: isFinite(GpuStats.powerFraction)
                    glyph: Icons.flash
                    value: GpuStats.powerFraction
                }

                GpuMeter {
                    visible: isFinite(GpuStats.fan)
                    glyph: Icons.fan
                    value: GpuStats.fan
                }
            }
        }

        VramBank {
            anchors.verticalCenter: parent.verticalCenter

            bank: 1
            used: root.used
        }
    }
}
