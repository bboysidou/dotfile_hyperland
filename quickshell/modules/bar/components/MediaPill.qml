import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums

Media {
    id: root

    property real budget: 0
    property string edge: BarEdge.top

    readonly property bool vertical: BarEdge.vertical(root.edge)

    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignVCenter
    Layout.leftMargin: root.vertical ? 0 : Appearance.bar.mediaMarginLeft
    Layout.topMargin: root.vertical ? Appearance.bar.mediaMarginLeft : 0

    controllable: true
    showElapsed: true
    compact: root.vertical
    availableWidth: Math.max(0, root.budget - root.x)
}
