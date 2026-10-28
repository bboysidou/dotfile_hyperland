import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.dashboard
import qs.services

MouseArea {
    id: root

    property string edge: BarEdge.top

    readonly property bool vertical: BarEdge.vertical(root.edge)

    Layout.alignment: Qt.AlignCenter

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: event => {
        if (event.button === Qt.RightButton)
            Launch.app(Commands.calendar);
        else
            DashState.toggle("");
    }
    onContainsMouseChanged: DashState.barHover = root.containsMouse

    GridLayout {
        id: layout

        anchors.fill: parent
        flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        rowSpacing: Appearance.spacing.small
        columnSpacing: Appearance.spacing.small

        Icon {
            Layout.alignment: Qt.AlignCenter

            text: Icons.clock
            color: DashState.opened ? Colours.accent : Colours.text
        }

        StyledText {
            Layout.alignment: Qt.AlignCenter

            text: root.vertical ? Qt.formatDateTime(Time.now, Appearance.bar.clockVerticalFormat) : Time.barText
            horizontalAlignment: Text.AlignHCenter
            color: DashState.opened ? Colours.textBright : Colours.text
        }
    }
}
