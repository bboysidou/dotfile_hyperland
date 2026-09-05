import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.modules.dashboard
import qs.services

MouseArea {
    id: root

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: event => {
        if (event.button === Qt.RightButton)
            Quickshell.execDetached(Commands.calendar);
        else
            DashState.toggle("");
    }
    onContainsMouseChanged: DashState.barHover = root.containsMouse

    RowLayout {
        id: layout

        anchors.fill: parent
        spacing: Appearance.spacing.small

        Icon {
            text: Icons.clock
            color: DashState.opened ? Colours.accent : Colours.text
        }

        StyledText {
            text: Time.barText
            color: DashState.opened ? Colours.textBright : Colours.text
        }
    }
}
