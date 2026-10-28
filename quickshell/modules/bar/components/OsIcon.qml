import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.settings

Icon {
    id: root

    property string edge: BarEdge.top

    readonly property bool vertical: BarEdge.vertical(root.edge)

    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignVCenter
    Layout.leftMargin: root.vertical ? 0 : Appearance.bar.archMarginLeft
    Layout.rightMargin: root.vertical ? 0 : Appearance.bar.archMarginRight
    Layout.topMargin: root.vertical ? Appearance.bar.archMarginLeft : 0
    Layout.bottomMargin: root.vertical ? Appearance.bar.archMarginRight : 0

    text: Icons.arch
    color: Colours.textBright

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: SettingsState.toggle()
    }
}
