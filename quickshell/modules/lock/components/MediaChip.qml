pragma ComponentBehavior: Bound

import qs.core.components
import qs.core.config
import qs.services

StyledRect {
    id: root

    visible: Players.available && media.label.length > 0

    implicitWidth: Appearance.lock.mediaMaxWidth
    implicitHeight: media.implicitHeight + Appearance.lock.statusPaddingV * 2

    color: Colours.pill
    radius: Appearance.lock.statusRounding

    Media {
        id: media

        anchors.centerIn: parent

        controllable: false
        showElapsed: true
        availableWidth: Appearance.lock.mediaMaxWidth - Appearance.lock.statusPaddingH * 2
    }
}
