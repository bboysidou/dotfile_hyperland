import QtQuick
import qs.core.config
import qs.core.components
import qs.modules.display.components
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    title: root.config.labelSystem
    glyph: Icons.updates

    SettingRow {
        label: root.config.labelUpdateCheck

        SegmentBar {
            width: root.config.segmentWidth

            options: root.config.updateChoices
            current: String(Prefs.updateMinutes)

            onSelected: key => Prefs.set("updateMinutes", Number(key))
        }
    }

    SettingRow {
        label: root.config.labelMouseWarn

        Stepper {
            stepperWidth: root.config.stepperWidth
            value: Prefs.mouseWarn > 0 ? Appearance.scale.percentTemplate.arg(Prefs.mouseWarn) : root.config.labelOff
            canDecrease: Prefs.mouseWarn > root.config.mouseWarnMin
            canIncrease: Prefs.mouseWarn < root.config.mouseWarnMax

            onStepped: delta => Prefs.stepValue("mouseWarn", delta, root.config.mouseWarnStep, root.config.mouseWarnMin, root.config.mouseWarnMax)
        }
    }
}
