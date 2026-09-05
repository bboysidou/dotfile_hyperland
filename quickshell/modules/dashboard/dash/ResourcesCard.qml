import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    readonly property real swapFraction: SysInfo.swapTotalKb > 0 ? SysInfo.swapUsedKb / SysInfo.swapTotalKb : 0

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    component Dial: Gauge {
        property real fraction: 0

        Layout.alignment: Qt.AlignHCenter

        size: Appearance.dash.resourceGaugeSize
        secondarySize: Appearance.dash.cardLabelSize
        value: fraction
        secondaryValue: fraction
        secondary: Appearance.scale.percentTemplate.arg(Math.round(fraction * Appearance.scale.percent))
    }

    ColumnLayout {
        id: layout

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        spacing: Appearance.dash.resourceSpacing

        Dial {
            icon: Icons.cpu
            colour: Colours.cpu
            fraction: SysInfo.cpuPercent / Appearance.scale.percent
        }

        Dial {
            icon: Icons.memory
            colour: Colours.memory
            fraction: SysInfo.memPercent / Appearance.scale.percent
        }

        Dial {
            icon: Icons.harddisk
            colour: Colours.storage
            fraction: root.swapFraction
        }
    }
}
