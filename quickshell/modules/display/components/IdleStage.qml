import QtQuick
import qs.core.components
import qs.core.config
import qs.services

OptionRow {
    id: root

    required property string toggleKey
    required property string secondsKey

    readonly property var config: Appearance.idle
    readonly property bool active: Idle.enabled && Idle[root.toggleKey]

    Toggle {
        enabled: Idle.enabled
        checked: Idle[root.toggleKey]

        onToggled: checked => Idle.set(root.toggleKey, checked)
    }

    Stepper {
        opacity: root.active ? 1 : Appearance.control.disabledOpacity
        stepperWidth: root.config.stepperWidth
        value: Idle.label(Idle[root.secondsKey])
        canDecrease: root.active && Idle[root.secondsKey] > root.config.minSeconds
        canIncrease: root.active && Idle[root.secondsKey] < root.config.maxSeconds

        onStepped: delta => Idle.step(root.secondsKey, delta)
    }
}
