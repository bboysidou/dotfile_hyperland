pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.modules.controlcenter.components
import qs.services

Panel {
    id: root

    property var pendingNetwork: null
    property var promptNetwork: null
    property var promptCard: null
    property string error: ""

    readonly property var orbiting: Net.networks.slice(0, Appearance.orbit.maxNodes)

    readonly property var connectionDetails: {
        const rows = [];

        if (Net.activeInterface !== "")
            rows.push({
                label: NetFields.labelInterface,
                value: Net.activeInterface
            });
        if (Net.mac !== "")
            rows.push({
                label: NetFields.labelMac,
                value: Net.mac
            });
        if (Net.address !== "")
            rows.push({
                label: NetFields.labelAddress,
                value: Net.address
            });
        if (Net.gateway !== "")
            rows.push({
                label: NetFields.labelGateway,
                value: Net.gateway
            });
        if (Net.dns !== "")
            rows.push({
                label: NetFields.labelDns,
                value: Net.dns
            });
        if (Net.activeNetwork)
            rows.push({
                label: NetFields.labelSecurity,
                value: Net.securityText(Net.activeNetwork)
            });

        return rows;
    }

    function detailFor(network): string {
        return root.statusFor(network) + Appearance.control.detailSeparator + Net.signalText(network);
    }

    function statusFor(network): string {
        const control = Appearance.control;
        if (Net.failed(network))
            return control.failureTimeout;
        if (network?.stateChanging)
            return control.labelConnecting;
        if (network?.connected)
            return control.labelConnected;
        if (network?.known)
            return control.labelSaved;
        return Net.securityText(network);
    }

    function dismiss(): void {
        const wasPrompting = root.promptNetwork !== null;
        root.promptNetwork = null;
        root.promptCard = null;
        root.error = "";

        if (wasPrompting && root.revealed)
            root.forceActiveFocus();
    }

    function reveal(card): void {
        const bottom = card.y + card.height;
        if (bottom > body.contentY + body.height)
            body.contentY = Math.min(bottom - body.height, Math.max(0, body.contentHeight - body.height));
        else if (card.y < body.contentY)
            body.contentY = card.y;
    }

    function activate(network): void {
        if (!network)
            return;

        if (root.promptNetwork === network) {
            root.dismiss();
            return;
        }

        if (network.connected) {
            Net.disconnectFrom(network);
            return;
        }

        if (Net.enterprise(network)) {
            Quickshell.execDetached(Commands.networkEditor);
            ControlState.hide();
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

    implicitWidth: Appearance.orbit.panelWidth

    onRevealedChanged: {
        if (!root.revealed)
            root.dismiss();
    }

    Connections {
        target: Net

        function onConnectStalled(network): void {
            if (root.pendingNetwork !== network)
                return;

            root.error = Appearance.control.failureTimeout;
            root.pendingNetwork = null;

            if (Net.secured(network) && !network.known)
                root.promptNetwork = network;
        }
    }

    Connections {
        target: root.pendingNetwork

        function onConnectionFailed(reason: int): void {
            root.error = Net.failureText(reason);
            root.promptNetwork = root.pendingNetwork;
            root.pendingNetwork = null;
            root.promptCard?.expansionItem?.reset();
            root.promptCard?.expansionItem?.focusInput();
        }
    }

    Binding {
        target: Net
        property: "scanning"
        value: ControlState.opened && ControlState.section === ControlSection.network
    }

    ColumnLayout {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: Appearance.control.paneSpacing

        PanelHeader {
            glyph: Net.glyph
            title: Appearance.control.labelNetwork
        }

        OrbitStage {
            id: stage

            Layout.fillWidth: true
            Layout.preferredHeight: Appearance.orbit.stageHeight

            powered: Net.wifiEnabled
            available: Net.wifiDevice !== null
            linked: Net.activeNetwork !== null || (Net.wiredDevice?.connected ?? false)
            glyph: Net.glyph
            accent: Colours.network

            nodes: root.orbiting.map(network => ({
                        source: network,
                        glyph: Glyphs.wifi(Net.signalPercent(network)),
                        label: network.name,
                        badge: "",
                        badgeGlyph: Net.secured(network) ? Icons.networkLocked : "",
                        active: network.connected,
                        busy: Net.busy(network),
                        failed: Net.failed(network) || (root.promptNetwork === network && root.error !== ""),
                        holdable: true,
                        forgettable: network.known
                    }))

            pinned: Net.wiredDevice ? [
                {
                    source: null,
                    glyph: Net.wiredDevice.connected ? Icons.ethernet : Icons.ethernetOff,
                    label: Net.wiredDevice.name,
                    badge: "",
                    badgeGlyph: "",
                    active: Net.wiredDevice.connected,
                    busy: false,
                    failed: false,
                    holdable: false
                }
            ] : []

            onNodeActivated: source => root.activate(source)
            onNodeHeld: source => Net.disconnectFrom(source)
            onNodeForgotten: source => Net.forgetNetwork(source)
            onPowerToggled: value => Net.setWifiEnabled(value)

            coreContent: Component {
                Item {
                    ColumnLayout {
                        anchors.centerIn: parent

                        width: parent.width - Appearance.orbit.coreSize / 3
                        spacing: Appearance.orbit.coreTextSpacing

                        Icon {
                            Layout.alignment: Qt.AlignHCenter

                            text: Net.glyph
                            color: Colours.surface
                            font.pixelSize: Appearance.orbit.nodeGlyphSize
                        }

                        StyledText {
                            Layout.fillWidth: true

                            text: Net.activeNetwork?.name ?? Appearance.orbit.labelOnline
                            color: Colours.surface
                            font.pixelSize: Appearance.orbit.coreLabelSize
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter

                            visible: Net.activeNetwork !== null
                            text: Appearance.scale.percentTemplate.arg(Net.signalPercent(Net.activeNetwork))
                            color: Colours.surface
                            font.pixelSize: Appearance.orbit.coreDetailSize
                        }
                    }
                }
            }

        }

    }

    PanelBody {
        id: body

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.control.paneSpacing

        InfoCard {
            visible: Net.wiredDevice !== null

            position: 0
            glyph: Net.wiredDevice?.connected ? Icons.ethernet : Icons.ethernetOff
            title: Net.wiredDevice?.name ?? ""
            detail: Net.wiredDevice?.connected ? Appearance.control.labelConnected : Appearance.control.failureDisconnected
            active: Net.wiredDevice?.connected ?? false
            accent: Colours.network
            details: Net.wiredDevice?.connected ? root.connectionDetails : []
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Appearance.control.rowPaddingH
            Layout.topMargin: Appearance.control.sectionContentSpacing

            visible: Net.networks.length > 0
            text: Appearance.orbit.labelFound.arg(Net.networks.length)
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        Repeater {
            model: Net.networks

            InfoCard {
                id: card

                required property var modelData
                required property int index

                position: index + 1
                glyph: Glyphs.wifi(Net.signalPercent(modelData))
                title: modelData.name
                detail: root.detailFor(modelData)
                badgeGlyph: Net.secured(modelData) ? Icons.networkLocked : ""
                active: modelData.connected
                accent: Colours.network
                forgettable: modelData.known
                details: modelData.connected ? root.connectionDetails : []
                expanded: root.promptNetwork === card.modelData

                onActivated: root.activate(card.modelData)
                onForgotten: Net.forgetNetwork(card.modelData)

                onExpandedChanged: {
                    if (card.expanded)
                        root.promptCard = card;
                }

                onExpansionReady: {
                    root.reveal(card);
                    card.expansionItem.focusInput();
                }

                expansion: Component {
                    PasswordPrompt {
                        networkName: card.modelData?.name ?? ""
                        error: root.error

                        onSubmitted: psk => root.submit(psk)
                        onCancelled: root.dismiss()
                    }
                }
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
    }
}
