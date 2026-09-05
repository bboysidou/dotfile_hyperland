pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.services

Item {
    id: root

    required property Notif popup
    required property color tint
    required property string glyph

    readonly property bool hasImage: popup.iconSource !== ""

    implicitWidth: Appearance.notif.iconSize
    implicitHeight: Appearance.notif.iconSize

    IconImage {
        anchors.fill: parent

        visible: root.hasImage
        source: root.popup.iconSource
    }

    Icon {
        anchors.centerIn: parent

        visible: !root.hasImage
        text: root.glyph
        color: root.tint
        font.pixelSize: Appearance.notif.iconSize
    }
}
