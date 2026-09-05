import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    Layout.rightMargin: Appearance.bar.pillMarginRight

    visible: Audio.available
    interactive: true
    scrollable: true

    onClicked: ControlState.toggle(ControlSection.audio)
    onScrolled: delta => Audio.step(delta > 0 ? Appearance.audio.step : -Appearance.audio.step)

    StyledText {
        text: Appearance.scale.percentTemplate.arg(Audio.percent)
    }

    Icon {
        text: Glyphs.volume(Audio.percent, Audio.muted)
    }

    Slider {
        Layout.leftMargin: Appearance.bar.volumeMarginLeft

        value: Audio.percent / Appearance.audio.max

        onMoved: value => Audio.setPercent(Math.round(value * Appearance.audio.max))
    }
}
