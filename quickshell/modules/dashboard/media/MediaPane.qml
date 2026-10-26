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
    property color accent: Colours.accent

    implicitWidth: Appearance.dash.mediaTabWidth
    implicitHeight: Appearance.dash.mediaTabHeight + Appearance.dash.spacing + equalizer.implicitHeight

    Item {
        id: player

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: Appearance.dash.mediaTabHeight

        EmptyState {
            anchors.centerIn: parent

            accent: root.accent
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
                    accent: root.accent
                }

                Details {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.alignment: Qt.AlignVCenter

                    accent: root.accent
                }
            }
        }
    }

    EqualizerCard {
        id: equalizer

        anchors.top: player.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.dash.spacing

        accent: root.accent
    }
}
