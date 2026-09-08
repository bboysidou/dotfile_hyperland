import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.dashboard
import qs.services

Pill {
    id: root

    visible: !!Prayer.next
    interactive: true

    color: "transparent"

    onClicked: DashState.show(DashSection.prayers)

    HoverHandler {
        onHoveredChanged: DashState.barHover = hovered
    }

    StyledRect {
        implicitWidth: Appearance.prayer.dividerWidth
        implicitHeight: Appearance.prayer.dividerHeight

        color: Colours.textMuted
        opacity: Appearance.prayer.dividerOpacity
    }

    Icon {
        text: Icons.prayersTab
        color: Prayer.urgent ? Colours.critical : Colours.textMuted
        font.pixelSize: Appearance.prayer.pillIconSize
    }

    StyledText {
        text: Prayer.next?.label ?? ""
        color: Prayer.urgent ? Colours.critical : Colours.text
        font.weight: Appearance.font.weightNormal
    }

    StyledText {
        text: Prayer.countdown
        color: Prayer.urgent ? Colours.critical : Colours.textMuted
        font.weight: Appearance.font.weightActive
    }
}
