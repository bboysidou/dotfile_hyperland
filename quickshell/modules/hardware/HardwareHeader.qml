import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

Item {
    id: root

    signal monitorRequested

    implicitHeight: Appearance.hardware.headerHeight

    RowLayout {
        anchors.fill: parent

        spacing: Appearance.hardware.headerSpacing

        Icon {
            text: Icons.hardware
            color: Colours.accent
            font.pixelSize: Appearance.hardware.headerIconSize
        }

        StyledText {
            Layout.fillWidth: true

            text: Appearance.hardware.title
            color: Colours.textBright
            font.weight: Appearance.font.weightActive
        }

        IconButton {
            icon: Icons.openExternal
            size: Appearance.hardware.actionSize

            onTriggered: root.monitorRequested()
        }
    }
}
