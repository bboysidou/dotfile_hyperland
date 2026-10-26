pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.display
import qs.services

ColumnLayout {
    id: root

    property color accent: Colours.accent

    readonly property var config: Appearance.display
    readonly property var draft: DisplayState.draft
    readonly property bool hdr: root.config.hdrPresets.includes(root.draft?.cm ?? "")

    function sdr(key: string, delta: int): void {
        const value = Num.clamp((root.draft?.[key] ?? 1) + delta * root.config.sdrStep, root.config.sdrMin, root.config.sdrMax);
        DisplayState.set(key, Math.round(value * 100) / 100);
    }

    spacing: 0

    OptionRow {
        label: root.config.labelVrr

        Repeater {
            model: root.config.vrrModes

            Chip {
                required property var modelData

                accent: root.accent
                label: modelData[0]
                active: (root.draft?.vrr ?? 0) === modelData[1]

                onTriggered: DisplayState.set("vrr", modelData[1])
            }
        }
    }

    OptionRow {
        label: root.config.labelBitdepth

        Repeater {
            model: root.config.bitdepths

            Chip {
                required property var modelData

                accent: root.accent
                label: modelData[0]
                active: (root.draft?.bitdepth ?? 8) === modelData[1]

                onTriggered: DisplayState.set("bitdepth", modelData[1])
            }
        }
    }

    OptionRow {
        label: root.config.labelCm

        Repeater {
            model: root.config.cmPresets

            Chip {
                required property string modelData

                accent: root.accent
                label: modelData
                active: (root.draft?.cm ?? root.config.defaultCm) === modelData

                onTriggered: DisplayState.set("cm", modelData)
            }
        }
    }

    OptionRow {
        visible: root.hdr
        label: root.config.labelSdrBrightness

        Stepper {
            value: (root.draft?.sdrbrightness ?? 1).toFixed(2)

            onStepped: delta => root.sdr("sdrbrightness", delta)
        }
    }

    OptionRow {
        visible: root.hdr
        label: root.config.labelSdrSaturation

        Stepper {
            value: (root.draft?.sdrsaturation ?? 1).toFixed(2)

            onStepped: delta => root.sdr("sdrsaturation", delta)
        }
    }

    OptionRow {
        label: root.config.labelDpms

        Toggle {
            accent: root.accent
            enabled: DisplayState.monitor !== Monitors.focused
            checked: DisplayState.current?.settings.dpms ?? true

            onToggled: checked => Displays.setDpms(DisplayState.monitor, checked)
        }
    }
}
