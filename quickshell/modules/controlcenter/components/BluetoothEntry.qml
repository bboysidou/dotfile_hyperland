pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.core.components
import qs.core.config
import qs.core.helpers

ListRow {
    id: root

    required property var device

    property bool confirming: false

    readonly property string glyph: Glyphs.btDevice(root.device.icon)
    readonly property int battery: Num.percent(root.device.battery)
    readonly property string status: {
        const control = Appearance.control;
        if (root.device.state === BluetoothDeviceState.Connecting)
            return control.labelConnecting;
        if (root.device.connected)
            return control.labelConnected;
        return "";
    }

    signal forgotten

    function reset(): void {
        root.confirming = false;
        countdown.stop();
    }

    function confirm(): void {
        if (root.confirming) {
            root.reset();
            root.forgotten();
        } else {
            root.confirming = true;
            countdown.restart();
        }
    }

    Keys.onReturnPressed: root.activated()
    Keys.onDeletePressed: root.confirm()

    onExited: root.reset()

    Timer {
        id: countdown

        interval: Appearance.control.forgetConfirmTimeout

        onTriggered: root.confirming = false
    }

    Icon {
        text: root.glyph
        color: root.device.connected ? Colours.highlight : Colours.text
        font.pixelSize: Appearance.control.iconSize
    }

    StyledText {
        Layout.fillWidth: true

        text: root.device.name
        color: root.device.connected ? Colours.textBright : Colours.text
        elide: Text.ElideRight
    }

    StyledText {
        visible: root.device.batteryAvailable

        text: Appearance.scale.percentTemplate.arg(root.battery)
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    StyledText {
        visible: root.status !== "" && !root.confirming

        text: root.status
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    StyledText {
        visible: root.confirming

        text: Appearance.control.labelForgetConfirm
        color: Colours.critical
        font.pixelSize: Appearance.font.size.small
    }

    Icon {
        visible: root.hovered || root.confirming

        text: Icons.forget
        color: root.confirming ? Colours.critical : Colours.textMuted
        font.pixelSize: Appearance.control.iconSize

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: root.confirm()
        }
    }
}
