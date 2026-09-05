pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.controlcenter.components
import qs.services

Pane {
    id: root

    function activate(device): void {
        if (!device)
            return;

        if (device.connected)
            Bt.disconnectDevice(device);
        else
            Bt.connectDevice(device);
    }

    PaneHeader {
        glyph: Glyphs.bluetooth(Bt.enabled, Bt.connected)
        title: Appearance.control.labelBluetooth

        control: Component {
            Toggle {
                checked: Bt.enabled
                enabled: Bt.available

                onToggled: value => Bt.setEnabled(value)
            }
        }
    }

    Repeater {
        model: Bt.devices

        BluetoothEntry {
            required property var modelData

            Layout.fillWidth: true

            device: modelData

            onActivated: root.activate(modelData)
            onForgotten: Bt.forgetDevice(modelData)
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.control.rowPaddingH

        visible: Bt.devices.length === 0
        text: {
            const control = Appearance.control;
            if (!Bt.available)
                return control.emptyNoBluetooth;
            if (!Bt.enabled)
                return control.emptyBluetoothDisabled;
            return control.emptyNoDevices;
        }
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }
}
