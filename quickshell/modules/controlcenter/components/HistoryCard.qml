import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

DetailCard {
    id: root

    readonly property bool hasCharge: BatteryHistory.charge.length >= 2
    readonly property bool hasRate: BatteryHistory.rate.length >= 2

    function span(values: var, template: string, decimals: int): string {
        if (values.length === 0)
            return "";
        const fixed = value => Number(value).toFixed(decimals);
        return template.arg(fixed(Math.min(...values))).arg(fixed(Math.max(...values)));
    }

    glyph: Icons.timer
    title: root.config.titleHistory

    trailing: SegmentBar {
        Layout.preferredWidth: root.config.spanWidth

        options: root.config.spans
        current: BatteryHistory.span

        onSelected: key => BatteryHistory.span = key
    }

    StyledText {
        Layout.fillWidth: true

        visible: !root.hasCharge && !root.hasRate
        text: root.config.emptyHistory
        color: Colours.textMuted
        font.pixelSize: root.config.detailSize
        wrapMode: Text.WordWrap
    }

    HistoryChart {
        visible: root.hasCharge
        title: root.config.titleCharge
        range: root.span(BatteryHistory.charge, root.config.percentRangeTemplate, 0)
        values: BatteryHistory.charge
        maximum: Appearance.scale.percent
        colour: Colours.accent
    }

    HistoryChart {
        visible: root.hasRate
        title: root.config.titleRate
        range: root.span(BatteryHistory.rate, root.config.wattRangeTemplate, Appearance.powerPanel.statDecimals)
        values: BatteryHistory.rate
        colour: Colours.netUp
    }
}
