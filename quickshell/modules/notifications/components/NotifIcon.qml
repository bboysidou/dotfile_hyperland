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

        visible: root.hasImage && root.popup.avatar === ""
        source: root.popup.avatar === "" ? root.popup.iconSource : ""
        asynchronous: true
    }

    ClippingRectangle {
        anchors.fill: parent

        visible: root.popup.avatar !== ""
        radius: Appearance.notif.iconSize / 2
        color: Colours.trough

        Image {
            anchors.fill: parent

            source: root.popup.avatar
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: Appearance.notif.iconSize * 2
            sourceSize.height: Appearance.notif.iconSize * 2
        }
    }

    ClippingRectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: root.popup.badge !== ""
        width: Appearance.notif.badgeSize
        height: Appearance.notif.badgeSize
        radius: Appearance.notif.badgeSize / 2
        color: Colours.trough

        Image {
            anchors.fill: parent

            source: root.popup.badge
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize.width: Appearance.notif.badgeSize * 2
            sourceSize.height: Appearance.notif.badgeSize * 2
        }
    }

    Icon {
        anchors.centerIn: parent

        visible: !root.hasImage
        text: root.glyph
        color: root.tint
        font.pixelSize: Appearance.notif.iconSize
    }
}
