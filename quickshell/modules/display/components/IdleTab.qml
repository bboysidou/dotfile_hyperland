import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

ColumnLayout {
    id: root

    property color accent: Colours.accent
    property int labelWidth: Appearance.display.labelWidth

    readonly property var config: Appearance.idle

    spacing: 0

    StyledText {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.display.gridSpacing

        text: Idle.enabled ? root.config.hintActive : root.config.hintDisabled
        color: Colours.textMuted
        wrapMode: Text.WordWrap
    }

    OptionRow {
        labelWidth: root.labelWidth
        label: root.config.labelEnabled

        Toggle {
            accent: root.accent
            checked: Idle.enabled

            onToggled: checked => Idle.set("enabled", checked)
        }
    }

    IdleStage {
        labelWidth: root.labelWidth
        accent: root.accent
        label: root.config.labelLock
        toggleKey: "lockOn"
        secondsKey: "lockSeconds"
    }

    IdleStage {
        labelWidth: root.labelWidth
        accent: root.accent
        label: root.config.labelScreenOff
        toggleKey: "screenOffOn"
        secondsKey: "screenOffSeconds"
    }

    IdleStage {
        labelWidth: root.labelWidth
        accent: root.accent
        label: root.config.labelSuspend
        toggleKey: "suspendOn"
        secondsKey: "suspendSeconds"
    }

    OptionRow {
        labelWidth: root.labelWidth
        label: root.config.labelBatteryOnly

        Toggle {
            accent: root.accent
            enabled: Idle.enabled && Idle.suspendOn
            checked: Idle.batteryOnly

            onToggled: checked => Idle.set("batteryOnly", checked)
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
