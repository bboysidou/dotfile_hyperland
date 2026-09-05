pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    readonly property var recent: NotifHistory.toArray().slice(0, Appearance.dash.notifCount)

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.notifNormal
            label: Appearance.dash.labelNotifications
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.recent.length === 0
            text: Appearance.dash.labelNoNotifications
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
            elide: Text.ElideRight
        }

        Repeater {
            model: root.recent

            NotificationPreview {
                required property var modelData

                Layout.fillWidth: true

                entry: modelData
            }
        }
    }
}
