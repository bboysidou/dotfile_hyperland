import QtQuick.Layouts
import qs.core.components
import qs.core.config

Media {
    id: root

    property real budget: 0

    Layout.leftMargin: Appearance.bar.mediaMarginLeft

    controllable: true
    showElapsed: true
    availableWidth: Math.max(0, root.budget - root.x)
}
