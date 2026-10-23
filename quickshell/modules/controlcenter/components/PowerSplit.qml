import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

DetailCard {
    id: root

    readonly property bool measured: BatteryHistory.cpuWatts >= 0
    readonly property real total: Battery.rate
    readonly property real cpu: Math.min(Math.max(0, BatteryHistory.cpuWatts), root.total)
    readonly property real rest: Math.max(0, root.total - root.cpu)

    function watts(value: real): string {
        return root.config.wattTemplate.arg(Number(value).toFixed(Appearance.powerPanel.statDecimals));
    }

    visible: Battery.discharging && Battery.rate > 0
    glyph: Icons.cpu
    title: root.config.titleSplit

    StyledText {
        Layout.fillWidth: true

        visible: !root.measured
        text: root.config.emptySplit
        color: Colours.textMuted
        font.pixelSize: root.config.detailSize
        wrapMode: Text.WordWrap
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: root.config.splitBarHeight

        visible: root.measured
        radius: root.config.splitBarRounding
        color: Colours.gpu

        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: root.total > 0 ? parent.width * root.cpu / root.total : 0
            radius: root.config.splitBarRounding
            color: Colours.cpu
        }
    }

    RowLayout {
        Layout.fillWidth: true

        visible: root.measured

        StyledText {
            text: `${root.config.labelCpu}  ${root.watts(root.cpu)}`
            color: Colours.cpu
            font.pixelSize: root.config.detailSize
            font.family: Appearance.font.family.mono
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            text: `${root.config.labelRest}  ${root.watts(root.rest)}`
            color: Colours.gpu
            font.pixelSize: root.config.detailSize
            font.family: Appearance.font.family.mono
        }
    }
}
