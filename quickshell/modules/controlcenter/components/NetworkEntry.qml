pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

ListRow {
    id: root

    required property var network

    readonly property int percent: Net.signalPercent(root.network)
    readonly property string status: {
        const control = Appearance.control;
        if (root.network.stateChanging)
            return control.labelConnecting;
        if (root.network.connected)
            return control.labelConnected;
        if (root.network.known)
            return control.labelSaved;
        return "";
    }

    Keys.onReturnPressed: root.activated()

    Icon {
        text: Glyphs.wifi(root.percent)
        color: root.network.connected ? Colours.highlight : Colours.text
        font.pixelSize: Appearance.control.iconSize
    }

    StyledText {
        Layout.fillWidth: true

        text: root.network.name
        color: root.network.connected ? Colours.textBright : Colours.text
        elide: Text.ElideRight
    }

    Icon {
        visible: Net.secured(root.network)

        text: Icons.networkLocked
        color: Colours.textMuted
        font.pixelSize: Appearance.control.iconSize
    }

    StyledText {
        visible: root.status !== ""

        text: root.status
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }
}
