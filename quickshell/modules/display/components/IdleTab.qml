import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

ColumnLayout {
    id: root

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
        label: root.config.labelEnabled

        Toggle {
            checked: Idle.enabled

            onToggled: checked => Idle.set("enabled", checked)
        }
    }

    IdleStage {
        label: root.config.labelLock
        toggleKey: "lockOn"
        secondsKey: "lockSeconds"
    }

    IdleStage {
        label: root.config.labelScreenOff
        toggleKey: "screenOffOn"
        secondsKey: "screenOffSeconds"
    }

    IdleStage {
        label: root.config.labelSuspend
        toggleKey: "suspendOn"
        secondsKey: "suspendSeconds"
    }

    OptionRow {
        label: root.config.labelBatteryOnly

        Toggle {
            enabled: Idle.enabled && Idle.suspendOn
            checked: Idle.batteryOnly

            onToggled: checked => Idle.set("batteryOnly", checked)
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
