import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    property bool armed: false

    title: root.config.labelClipboard
    glyph: Icons.clipboard

    SettingRow {
        label: root.config.labelClipMaxItems

        Stepper {
            stepperWidth: root.config.stepperWidth
            value: String(Prefs.clipMaxItems)
            canDecrease: Prefs.clipMaxItems > root.config.clipItemsMin
            canIncrease: Prefs.clipMaxItems < root.config.clipItemsMax

            onStepped: delta => Prefs.stepValue("clipMaxItems", delta, root.config.clipItemsStep, root.config.clipItemsMin, root.config.clipItemsMax)
        }
    }

    SettingRow {
        label: root.config.labelClipMaxAge

        SegmentBar {
            width: root.config.segmentWidth

            options: root.config.clipAgeChoices
            current: String(Prefs.clipMaxDays)

            onSelected: key => Prefs.set("clipMaxDays", Number(key))
        }
    }

    SettingRow {
        label: root.config.labelClipImages

        Toggle {
            checked: Prefs.clipImages

            onToggled: checked => Prefs.set("clipImages", checked)
        }
    }

    SettingRow {
        label: root.config.labelClipClear.arg(Clipboard.total)

        Chip {
            label: root.armed ? root.config.labelConfirm : root.config.labelClear
            active: root.armed
            accent: Colours.critical

            onTriggered: {
                if (root.armed)
                    Clipboard.wipe();
                root.armed = !root.armed;
            }
        }
    }

    Timer {
        running: root.armed
        interval: root.config.confirmTimeout

        onTriggered: root.armed = false
    }
}
