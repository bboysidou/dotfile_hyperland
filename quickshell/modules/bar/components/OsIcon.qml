import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.settings

Icon {
    Layout.leftMargin: Appearance.bar.archMarginLeft
    Layout.rightMargin: Appearance.bar.archMarginRight

    text: Icons.arch
    color: Colours.textBright

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: SettingsState.toggle()
    }
}
