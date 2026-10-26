pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter.panels
import qs.modules.hardware.components
import qs.services

Panel {
    id: root

    readonly property var accents: ({
            [HardwareSection.cpu]: Colours.cpu,
            [HardwareSection.gpu]: Colours.gpu,
            [HardwareSection.memory]: Colours.memory
        })

    readonly property var sections: ({
            [HardwareSection.cpu]: cpuSection,
            [HardwareSection.gpu]: gpuSection,
            [HardwareSection.memory]: memorySection
        })

    function step(delta: int): void {
        const values = HardwareSection.values;
        HardwareState.show(values[Num.wrap(values.indexOf(HardwareState.section), delta, values.length)]);
    }

    function rescan(): void {
        HardwareState.rescan();
        Launch.app(Terminal.command(Commands.hardwareSetup));
        HardwareState.hide();
    }

    outlineColour: tabBar.fill
    implicitWidth: Appearance.hardware.width
    scaleFrom: Appearance.hardware.scaleFrom

    Keys.onPressed: event => {
        const sections = Nav.horizontal(event);
        if (sections !== 0) {
            root.step(sections);
            event.accepted = true;
        }
    }

    ColumnLayout {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: Appearance.spacing.none

        HardwareHeader {
            Layout.fillWidth: true

            onRescanRequested: root.rescan()
        }

        SegmentBar {
            id: tabBar

            Layout.fillWidth: true
            Layout.topMargin: Appearance.hardware.switchTopMargin

            current: HardwareState.section
            accent: root.accents[HardwareState.section] ?? Colours.accent
            options: [
                {
                    key: HardwareSection.cpu,
                    label: Appearance.hardware.labelCpu
                },
                {
                    key: HardwareSection.gpu,
                    label: Appearance.hardware.labelGpu
                },
                {
                    key: HardwareSection.memory,
                    label: Appearance.hardware.labelMemory
                }
            ]

            onSelected: key => HardwareState.show(key)
        }
    }

    PanelBody {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.hardware.bodyTopMargin

        Loader {
            Layout.fillWidth: true

            active: root.revealed || root.visible
            sourceComponent: root.sections[HardwareState.section] ?? null
        }
    }

    Component {
        id: cpuSection

        CpuSection {}
    }

    Component {
        id: gpuSection

        GpuSection {}
    }

    Component {
        id: memorySection

        MemorySection {}
    }
}
