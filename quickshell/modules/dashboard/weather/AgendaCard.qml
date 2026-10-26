import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

Item {
    id: root

    property string title
    property string time
    property string place

    readonly property var config: Appearance.weather

    implicitWidth: root.config.agendaCardWidth
    implicitHeight: root.config.agendaCardHeight

    StyledRect {
        width: root.config.agendaRuleWidth
        height: parent.height
        color: Colours.border
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: root.config.agendaPadding

        spacing: root.config.agendaSpacing

        ScrollText {
            Layout.fillWidth: true

            text: root.title
            color: Colours.textBright
            font.pixelSize: root.config.agendaTitleSize
            font.bold: true
        }

        RowLayout {
            spacing: root.config.agendaSpacing

            Icon {
                text: Icons.clockOutline
                color: Colours.textMuted
                font.pixelSize: root.config.agendaDetailSize
            }

            StyledText {
                text: root.time
                color: Colours.text
                font.pixelSize: root.config.agendaDetailSize
            }
        }

        RowLayout {
            Layout.fillWidth: true

            visible: root.place !== ""
            spacing: root.config.agendaSpacing

            Icon {
                text: Icons.mapMarker
                color: Colours.textMuted
                font.pixelSize: root.config.agendaDetailSize
            }

            ScrollText {
                Layout.fillWidth: true

                text: root.place
                color: Colours.textMuted
                font.pixelSize: root.config.agendaDetailSize
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
