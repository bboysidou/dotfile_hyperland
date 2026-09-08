pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.services

Panel {
    id: root

    readonly property var orbiting: Bt.devices.slice(0, Appearance.orbit.maxNodes)
    readonly property var activeDevice: Bt.devices.find(device => device.connected) ?? null

    readonly property var deviceDetails: {
        const device = root.activeDevice;
        if (!device)
            return [];

        const rows = [];

        if (Bt.adapter?.name)
            rows.push({
                label: Appearance.control.labelAdapter,
                value: Bt.adapter.name
            });
        if (device.batteryAvailable)
            rows.push({
                label: Appearance.control.labelBattery,
                value: Appearance.scale.percentTemplate.arg(Num.percent(device.battery))
            });

        return rows;
    }

    function activate(device): void {
        Bt.activateDevice(device);
    }

    function detailFor(device): string {
        return Bt.statusText(device) + Appearance.control.detailSeparator + (device?.address ?? "");
    }

    implicitWidth: Appearance.orbit.panelWidth

    Binding {
        target: Bt
        property: "discovering"
        value: ControlState.opened && ControlState.section === ControlSection.bluetooth
    }

    ColumnLayout {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: Appearance.control.paneSpacing

        PanelHeader {
            glyph: Glyphs.bluetooth(Bt.enabled, Bt.connected)
            title: Appearance.control.labelBluetooth

            control: Component {
                IconButton {
                    icon: Icons.refresh
                    size: Appearance.control.scanIconSize
                    disabled: !Bt.enabled || !Bt.available

                    onTriggered: Bt.rescan()

                    NumberAnimation on rotation {
                        running: Bt.rescanning
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        from: 0
                        to: 360
                        duration: Appearance.control.scanSpinDuration
                    }
                }
            }
        }

        OrbitStage {
            Layout.fillWidth: true
            Layout.preferredHeight: Appearance.orbit.stageHeight

            powered: Bt.enabled
            available: Bt.available
            linked: Bt.connected > 0
            glyph: Glyphs.bluetooth(Bt.enabled, Bt.connected)
            accent: Colours.bluetooth

            nodes: root.orbiting.map(device => ({
                        source: device,
                        glyph: Glyphs.btDevice(device.icon ?? ""),
                        label: device.name,
                        badge: device.batteryAvailable ? Appearance.scale.percentTemplate.arg(Num.percent(device.battery)) : "",
                        badgeGlyph: "",
                        active: device.connected,
                        busy: Bt.busy(device),
                        failed: Bt.failed(device),
                        holdable: true,
                        forgettable: true
                    }))

            onNodeActivated: source => root.activate(source)
            onNodeHeld: source => Bt.disconnectDevice(source)
            onNodeForgotten: source => Bt.forgetDevice(source)
            onPowerToggled: value => Bt.setEnabled(value)

            coreContent: Component {
                Item {
                    ColumnLayout {
                        anchors.centerIn: parent

                        width: parent.width - Appearance.orbit.coreSize / 3
                        spacing: Appearance.orbit.coreTextSpacing

                        Icon {
                            Layout.alignment: Qt.AlignHCenter

                            text: Icons.bluetoothConnected
                            color: Colours.surface
                            font.pixelSize: Appearance.orbit.nodeGlyphSize
                        }

                        StyledText {
                            Layout.fillWidth: true

                            text: root.activeDevice?.name ?? ""
                            color: Colours.surface
                            font.pixelSize: Appearance.orbit.coreLabelSize
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter

                            visible: Bt.connected > 1
                            text: Appearance.orbit.labelExtra.arg(Bt.connected - 1)
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

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Appearance.control.rowPaddingH
            Layout.topMargin: Appearance.control.sectionContentSpacing

            visible: Bt.devices.length > 0
            text: Appearance.orbit.labelFound.arg(Bt.devices.length)
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        Repeater {
            model: Bt.devices

            InfoCard {
                required property var modelData
                required property int index

                position: index
                glyph: Glyphs.btDevice(modelData.icon ?? "")
                title: modelData.name
                detail: root.detailFor(modelData)
                badge: modelData.batteryAvailable ? Appearance.scale.percentTemplate.arg(Num.percent(modelData.battery)) : ""
                active: modelData.connected
                accent: Colours.bluetooth
                forgettable: modelData.paired
                details: modelData.connected ? root.deviceDetails : []

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
}
