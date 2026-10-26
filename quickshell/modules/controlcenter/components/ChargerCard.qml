import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

DetailCard {
    id: root

    function fixed(value: real): string {
        return Number(value).toFixed(root.config.chargerDecimals);
    }

    readonly property string headline: {
        if (!Charger.connected)
            return root.config.labelUnplugged;
        return Charger.watts > 0 ? root.config.wattTemplate.arg(root.fixed(Charger.watts)) : root.config.labelPlugged;
    }

    readonly property string detail: [Charger.usbType !== "" ? root.config.usbTemplate.arg(Charger.usbType) : Charger.kind, Charger.volts > 0 && Charger.amps > 0 ? root.config.contractTemplate.arg(root.fixed(Charger.volts)).arg(root.fixed(Charger.amps)) : ""].filter(part => part !== "").join("  ·  ")

    glyph: Icons.powerPlug
    title: root.config.titleCharger

    RowLayout {
        Layout.fillWidth: true

        spacing: root.config.cardSpacing

        StyledText {
            text: root.headline
            color: Charger.connected ? Colours.textBright : Colours.textMuted
            font.pixelSize: root.config.valueSize
            font.family: Appearance.font.family.mono
        }

        ScrollText {
            Layout.fillWidth: true

            visible: Charger.connected
            text: root.detail
            color: Colours.textMuted
            font.pixelSize: root.config.detailSize
            horizontalAlignment: Text.AlignRight
        }
    }
}
