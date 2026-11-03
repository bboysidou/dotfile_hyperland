import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    leading: Appearance.bar.idleMarginLeft
    trailing: Appearance.bar.idleMarginRight

    interactive: true
    secondary: true

    onClicked: ControlState.toggle(ControlSection.idle)
    onSecondaryClicked: Idle.set("enabled", !Idle.enabled)

    Icon {
        text: Idle.enabled ? Icons.sleep : Icons.coffee
        color: Idle.enabled ? Colours.text : Colours.accent
    }
}
