pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    title: root.config.labelKeyboard
    glyph: Icons.keyboard

    Repeater {
        model: InputPrefs.layouts

        SettingRow {
            required property var modelData

            label: modelData.layout

            Stepper {
                stepperWidth: root.config.stepperWidth * 2
                value: modelData.variant || root.config.labelDefaultVariant

                onStepped: delta => {
                    InputPrefs.loadVariants(modelData.layout);
                    InputPrefs.cycleVariant(modelData.layout, delta);
                }

                Component.onCompleted: InputPrefs.loadVariants(modelData.layout)
            }

            IconButton {
                icon: Icons.close
                disabled: InputPrefs.layouts.length <= 1

                onTriggered: InputPrefs.removeLayout(modelData.layout)
            }
        }
    }

    SearchPick {
        visible: InputPrefs.layouts.length < root.config.maxLayouts
        placeholder: root.config.placeholderLayout
        choices: InputPrefs.available
        exclude: InputPrefs.layouts.map(entry => entry.layout)

        onPicked: value => InputPrefs.addLayout(value)
    }

    SettingRow {
        visible: InputPrefs.layouts.length > 1
        label: root.config.labelSwitchKey

        Repeater {
            model: root.config.switchKeys

            Chip {
                required property var modelData

                label: modelData[0]
                active: InputPrefs.switchKey === modelData[1]

                onTriggered: InputPrefs.setSwitchKey(modelData[1])
            }
        }
    }
}
