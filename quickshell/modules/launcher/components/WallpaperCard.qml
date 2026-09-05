pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

Item {
    id: root

    required property string modelData

    readonly property bool current: root.PathView.isCurrentItem
    readonly property bool onPath: root.PathView.onPath
    readonly property int thumbWidth: Appearance.launcher.wallpaperItemWidth
    readonly property int thumbHeight: Math.round(root.thumbWidth * Appearance.launcher.wallpaperAspect)

    signal clicked

    implicitWidth: root.thumbWidth + Appearance.launcher.wallpaperItemPadding * 2
    implicitHeight: root.thumbHeight + Appearance.launcher.wallpaperLabelSpacing + Appearance.launcher.wallpaperLabelHeight + Appearance.launcher.wallpaperItemPadding * 2

    z: root.PathView.z ?? 0
    scale: root.current ? 1 : root.onPath ? Appearance.launcher.wallpaperSideScale : 0
    opacity: root.onPath ? 1 : 0

    Behavior on scale {
        Anim {
            type: AnimType.fastSpatial
            duration: Appearance.anim.durations.fastEffects
        }
    }

    Behavior on opacity {
        Anim {
            type: AnimType.fastEffects
        }
    }

    Elevation {
        anchors.fill: frame

        radius: frame.radius
        level: Appearance.launcher.wallpaperElevation
        opacity: root.current ? 1 : 0

        Behavior on opacity {
            Anim {
                type: AnimType.defaultEffects
            }
        }
    }

    ClippingRectangle {
        id: frame

        anchors.top: parent.top
        anchors.topMargin: Appearance.launcher.wallpaperItemPadding
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: root.thumbWidth
        implicitHeight: root.thumbHeight

        color: Colours.trough
        radius: Appearance.launcher.wallpaperItemRounding

        Image {
            anchors.fill: parent

            source: `file://${root.modelData}`
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(root.thumbWidth, root.thumbHeight)
        }
    }

    StyledText {
        anchors.top: frame.bottom
        anchors.topMargin: Appearance.launcher.wallpaperLabelSpacing
        anchors.horizontalCenter: parent.horizontalCenter

        width: frame.width
        text: Wallpaper.name(root.modelData)
        color: root.current ? Colours.textBright : Colours.textMuted
        font.pixelSize: Appearance.font.size.tiny
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignHCenter
    }

    StateLayer {
        radius: Appearance.launcher.wallpaperItemRounding

        onClicked: root.clicked()
    }
}
