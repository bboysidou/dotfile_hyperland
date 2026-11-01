pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.services

Item {
    id: root

    required property string source
    required property string avatar
    required property string badge
    required property color tint
    required property string glyph
    property int size: Appearance.notif.iconSize

    signal avatarLoaded(Item image)

    readonly property bool hasImage: root.source !== ""
    readonly property real badgeSize: Appearance.notif.badgeSize * root.size / Appearance.notif.iconSize

    implicitWidth: root.size
    implicitHeight: root.size

    IconImage {
        anchors.fill: parent

        visible: root.hasImage && root.avatar === ""
        source: root.avatar === "" ? root.source : ""
        asynchronous: true
    }

    ClippingRectangle {
        anchors.fill: parent

        visible: root.avatar !== ""
        radius: root.size / 2
        color: Colours.trough

        Image {
            anchors.fill: parent

            id: avatarImage

            source: root.avatar
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: root.size * 2
            sourceSize.height: root.size * 2

            onStatusChanged: {
                if (avatarImage.status === Image.Ready)
                    root.avatarLoaded(avatarImage);
            }
        }
    }

    ClippingRectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: root.badge !== ""
        width: root.badgeSize
        height: root.badgeSize
        radius: root.badgeSize / 2
        color: Colours.trough

        Image {
            anchors.fill: parent

            source: root.badge
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize.width: root.badgeSize * 2
            sourceSize.height: root.badgeSize * 2
        }
    }

    Icon {
        anchors.centerIn: parent

        visible: !root.hasImage
        text: root.glyph
        color: root.tint
        font.pixelSize: root.size
    }
}
