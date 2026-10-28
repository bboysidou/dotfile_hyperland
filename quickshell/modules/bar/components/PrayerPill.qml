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
        visible: !root.vertical
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
        visible: !root.vertical
        text: Prayer.next?.label ?? ""
        color: Prayer.urgent ? Colours.critical : Colours.text
        font.weight: Appearance.font.weightNormal
    }

    StyledText {
        text: root.vertical ? Prayer.countdown.replace(" ", "\n") : Prayer.countdown
        horizontalAlignment: Text.AlignHCenter
        color: Prayer.urgent ? Colours.critical : Colours.textMuted
        font.weight: Appearance.font.weightActive
    }
}
