import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.display.components
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    title: root.config.labelLook
    glyph: Icons.palette

    SettingRow {
        label: root.config.labelFont

        StyledText {
            anchors.verticalCenter: parent.verticalCenter

            text: Appearance.font.family.sans
            color: Colours.textBright
            font.family: Appearance.font.family.sans
        }

        Chip {
            visible: Prefs.font !== ""
            label: root.config.labelReset

            onTriggered: Prefs.set("font", "")
        }
    }

    SearchPick {
        placeholder: root.config.placeholderFont
        choices: Qt.fontFamilies()
        exclude: [Appearance.font.family.sans]

        onPicked: value => Prefs.set("font", value)
    }

    SettingRow {
        label: root.config.labelTextSize

        Stepper {
            stepperWidth: root.config.stepperWidth
            value: root.config.percentTemplate.arg(Math.round(Prefs.textScale * Appearance.scale.percent))
            canDecrease: Prefs.textScale > root.config.scaleMin
            canIncrease: Prefs.textScale < root.config.scaleMax

            onStepped: delta => Prefs.stepScale(delta)
        }
    }

    SettingRow {
        label: root.config.labelPanelOutline

        SegmentBar {
            width: root.config.segmentWidth

            options: OutlineMode.values.map(mode => ({
                        key: mode,
                        label: OutlineMode.labels[mode]
                    }))
            current: Prefs.panelOutline

            onSelected: key => Prefs.set("panelOutline", key)
        }
    }
}
