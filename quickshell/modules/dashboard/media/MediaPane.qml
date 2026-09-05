import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.dashboard.components
import qs.services

Item {
    id: root

    property bool active: true

    implicitWidth: Appearance.dash.mediaTabWidth
    implicitHeight: Appearance.dash.mediaTabHeight

    EmptyState {
        anchors.centerIn: parent

        glyph: Icons.mediaTab
        title: Appearance.dash.emptyTitle
        subtitle: Appearance.dash.emptySubtitle
        opacity: Players.available ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            Anim {
                type: AnimType.defaultEffects
            }
        }
    }

    Card {
        anchors.fill: parent

        opacity: Players.available ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            Anim {
                type: AnimType.defaultEffects
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.dash.cardPadding

            spacing: Appearance.dash.spacing * 2

            Vinyl {
                Layout.alignment: Qt.AlignVCenter

                active: root.active
            }

            Details {
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
