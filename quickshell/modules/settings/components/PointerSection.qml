import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.services

ColumnLayout {
    id: root

    readonly property var config: Appearance.settings

    Layout.fillWidth: true

    spacing: root.config.listSpacing

    SettingsSection {
        title: root.config.labelMouse
        glyph: Icons.mouse

        SettingRow {
            label: root.config.labelSensitivity

            Stepper {
                stepperWidth: root.config.stepperWidth
                value: root.config.sensitivityTemplate.arg(InputPrefs.sensitivity.toFixed(root.config.sensitivityDecimals))
                canDecrease: InputPrefs.sensitivity > root.config.sensitivityMin
                canIncrease: InputPrefs.sensitivity < root.config.sensitivityMax

                onStepped: delta => InputPrefs.stepSensitivity(delta)
            }
        }

        SettingRow {
            label: root.config.labelFlatAccel

            Toggle {
                checked: InputPrefs.flat

                onToggled: checked => InputPrefs.set("flat", checked)
            }
        }

        SettingRow {
            label: root.config.labelNaturalScroll

            Toggle {
                checked: InputPrefs.naturalScroll

                onToggled: checked => InputPrefs.set("naturalScroll", checked)
            }
        }
    }

    SettingsSection {
        title: root.config.labelTouchpad
        glyph: Icons.mouse

        StyledText {
            Layout.fillWidth: true

            visible: !InputPrefs.hasTouchpad
            text: root.config.hintNoTouchpad
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WordWrap
        }

        SettingRow {
            label: root.config.labelNaturalScroll

            Toggle {
                checked: InputPrefs.touchNatural

                onToggled: checked => InputPrefs.set("touchNatural", checked)
            }
        }

        SettingRow {
            label: root.config.labelTapToClick

            Toggle {
                checked: InputPrefs.tapToClick

                onToggled: checked => InputPrefs.set("tapToClick", checked)
            }
        }

        SettingRow {
            label: root.config.labelDisableWhileTyping

            Toggle {
                checked: InputPrefs.disableWhileTyping

                onToggled: checked => InputPrefs.set("disableWhileTyping", checked)
            }
        }
    }
}
