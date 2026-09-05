pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.modules.controlcenter.components
import qs.services

Pane {
    id: root

    property var pendingNetwork: null
    property var promptNetwork: null
    property string error: ""

    signal closeRequested

    function dismiss(): void {
        const wasPrompting = root.promptNetwork !== null;
        root.promptNetwork = null;
        root.error = "";
        prompt.reset();

        if (wasPrompting)
            root.forceActiveFocus();
    }

    function activate(network): void {
        if (!network)
            return;

        if (network.connected) {
            Net.disconnectFrom(network);
            return;
        }

        if (Net.enterprise(network)) {
            Quickshell.execDetached(Commands.networkEditor);
            root.closeRequested();
            return;
        }

        if (network.known || !Net.secured(network)) {
            root.pendingNetwork = network;
            root.error = "";
            Net.connectTo(network);
            return;
        }

        root.promptNetwork = network;
        root.error = "";
        prompt.reset();
        prompt.focusInput();
    }

    function submit(psk: string): void {
        const network = root.promptNetwork;
        if (!network)
            return;

        root.pendingNetwork = network;
        root.error = "";
        Net.connectToWithPsk(network, psk);
        root.dismiss();
    }

    PaneHeader {
        glyph: Net.glyph
        title: Appearance.control.labelNetwork

        control: Component {
            Toggle {
                checked: Net.wifiEnabled
                enabled: Net.wifiHardwareEnabled

                onToggled: value => Net.setWifiEnabled(value)
            }
        }
    }

    Connections {
        target: root.pendingNetwork

        function onConnectionFailed(reason: int): void {
            root.error = Net.failureText(reason);
            root.promptNetwork = root.pendingNetwork;
            root.pendingNetwork = null;
            prompt.reset();
            prompt.focusInput();
        }
    }

    StyledRect {
        Layout.fillWidth: true

        visible: Net.wiredDevice !== null
        color: "transparent"

        implicitHeight: Appearance.control.rowHeight

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.control.rowPaddingH
            anchors.rightMargin: Appearance.control.rowPaddingH

            spacing: Appearance.control.rowSpacing

            Icon {
                text: Net.wiredDevice?.connected ? Icons.ethernet : Icons.ethernetOff
                color: Net.wiredDevice?.connected ? Colours.highlight : Colours.textMuted
                font.pixelSize: Appearance.control.iconSize
            }

            StyledText {
                Layout.fillWidth: true

                text: Net.wiredDevice?.name ?? ""
                color: Colours.text
                elide: Text.ElideRight
            }

            StyledText {
                visible: Net.wiredDevice?.connected ?? false

                text: Appearance.control.labelConnected
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }
        }
    }

    Repeater {
        model: Net.networks

        NetworkEntry {
            required property var modelData

            Layout.fillWidth: true

            network: modelData

            onActivated: root.activate(modelData)
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.control.rowPaddingH

        visible: Net.networks.length === 0
        text: {
            const control = Appearance.control;
            if (!Net.wifiDevice)
                return control.emptyNoWifiDevice;
            if (!Net.wifiEnabled)
                return control.emptyWifiDisabled;
            return control.emptyScanning;
        }
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    PasswordPrompt {
        id: prompt

        Layout.fillWidth: true
        Layout.topMargin: Appearance.control.sectionContentSpacing

        visible: root.promptNetwork !== null
        networkName: root.promptNetwork?.name ?? ""
        error: root.error

        onSubmitted: psk => root.submit(psk)
        onCancelled: root.dismiss()
    }
}
