import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

Item {
    id: root

    implicitHeight: layout.implicitHeight || 0

    component Lane: RowLayout {
        id: lane

        property string icon: ""
        property real rate: 0
        property var history: []
        property color colour: Colours.accent

        Layout.fillWidth: true
        Layout.preferredHeight: Appearance.dash.netSparkHeight

        spacing: Appearance.dash.cardSpacing

        Icon {
            text: lane.icon
            color: lane.colour
            font.pixelSize: Appearance.dash.cardLabelSize
        }

        StyledText {
            Layout.preferredWidth: Appearance.dash.netRateWidth

            text: Fmt.rate(lane.rate)
            color: Colours.textBright
            font.weight: Appearance.font.weightActive
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.preferredHeight: Appearance.dash.netSparkHeight

            values: lane.history
            maximum: Appearance.dash.netScaleFloor
            colour: lane.colour
        }
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        spacing: Appearance.dash.perfRowSpacing

        Lane {
            icon: Icons.download
            rate: SysInfo.netDownRate
            history: SysInfo.netDownHistory
            colour: Colours.netDown
        }

        Lane {
            icon: Icons.upload
            rate: SysInfo.netUpRate
            history: SysInfo.netUpHistory
            colour: Colours.netUp
        }
    }
}
