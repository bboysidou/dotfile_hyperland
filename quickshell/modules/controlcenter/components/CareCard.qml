import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

DetailCard {
    id: root

    readonly property var limits: root.config.limitPresets.map(preset => ({
                key: String(preset),
                label: root.config.limitTemplate.arg(preset)
            }))
    readonly property var modes: Battery.chargeTypes.options.map(option => ({
                key: option,
                label: option.replace(/_/g, " ")
            }))

    visible: BatteryCare.supported
    glyph: Icons.leaf
    title: root.config.titleCare

    StyledText {
        Layout.fillWidth: true

        visible: BatteryCare.locked || BatteryCare.failed
        text: BatteryCare.locked ? root.config.labelLocked : root.config.labelFailed
        color: BatteryCare.locked ? Colours.warning : Colours.critical
        font.pixelSize: root.config.detailSize
        wrapMode: Text.WordWrap
    }

    StyledText {
        visible: BatteryCare.hasLimit
        text: root.config.labelLimit
        color: Colours.text
    }

    SegmentBar {
        Layout.fillWidth: true

        visible: BatteryCare.hasLimit
        enabled: BatteryCare.canLimit
        options: root.limits
        current: String(Battery.limit)

        onSelected: key => BatteryCare.setLimit(Number(key))
    }

    RowLayout {
        Layout.fillWidth: true

        visible: BatteryCare.hasHold
        spacing: root.config.cardSpacing

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 0

            ScrollText {
                Layout.fillWidth: true

                text: root.config.labelHold
                color: Colours.text
            }

            ScrollText {
                Layout.fillWidth: true

                text: root.config.detailHold
                color: Colours.textMuted
                font.pixelSize: root.config.detailSize
            }
        }

        Toggle {
            Layout.alignment: Qt.AlignVCenter

            enabled: BatteryCare.canHold
            checked: BatteryCare.holding

            onToggled: BatteryCare.setHold(!BatteryCare.holding)
        }
    }

    StyledText {
        visible: BatteryCare.hasMode
        text: root.config.labelMode
        color: Colours.text
    }

    SegmentBar {
        Layout.fillWidth: true

        visible: BatteryCare.hasMode
        enabled: BatteryCare.canMode
        options: root.modes
        current: Battery.chargeTypes.current

        onSelected: key => BatteryCare.setChargeType(key)
    }
}
