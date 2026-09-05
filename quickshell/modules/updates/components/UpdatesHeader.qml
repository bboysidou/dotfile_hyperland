import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Item {
    id: root

    signal upgradeRequested

    implicitHeight: Appearance.updates.headerHeight

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.updates.rowPaddingH
        anchors.rightMargin: Appearance.updates.rowPaddingH

        spacing: Appearance.updates.headerSpacing

        Icon {
            text: Icons.updates
            color: Colours.accent
            font.pixelSize: Appearance.updates.headerIconSize
        }

        StyledText {
            text: Appearance.updates.title
            color: Colours.textBright
            font.weight: Appearance.font.weightActive
        }

        StyledText {
            Layout.fillWidth: true

            text: Updates.count
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        IconButton {
            icon: Icons.refresh
            size: Appearance.updates.actionSize
            disabled: Updates.refreshing

            onTriggered: Updates.refresh()

            NumberAnimation on rotation {
                running: Updates.refreshing
                loops: Animation.Infinite
                alwaysRunToEnd: true
                from: 0
                to: 360
                duration: Appearance.updates.spinDuration
            }
        }

        IconButton {
            Layout.leftMargin: Appearance.updates.actionSpacing

            icon: Icons.download
            size: Appearance.updates.actionSize
            accent: true
            disabled: !Updates.available

            onTriggered: root.upgradeRequested()
        }
    }
}
