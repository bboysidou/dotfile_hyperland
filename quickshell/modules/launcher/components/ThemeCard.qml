pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

Item {
    id: root

    required property string modelData

    readonly property var scheme: Colours.paletteFor(root.modelData)
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

    Rectangle {
        id: frame

        anchors.top: parent.top
        anchors.topMargin: Appearance.launcher.wallpaperItemPadding
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: root.thumbWidth
        implicitHeight: root.thumbHeight

        color: root.scheme.bg
        radius: Appearance.launcher.wallpaperItemRounding
        border.width: Appearance.theme.frameBorder
        border.color: root.current ? root.scheme.accent : root.scheme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.theme.mockPadding

            spacing: Appearance.theme.mockLineSpacing

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Appearance.theme.mockBarHeight

                color: root.scheme.bgAlt
                radius: height / 2

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    width: Appearance.theme.mockPillWidth
                    height: parent.height
                    color: root.scheme.accent
                    radius: height / 2
                }
            }

            Rectangle {
                Layout.preferredWidth: parent.width * Appearance.theme.mockLineLong
                Layout.preferredHeight: Appearance.theme.mockLineHeight

                color: root.scheme.fg
                radius: height / 2
            }

            Rectangle {
                Layout.preferredWidth: parent.width * Appearance.theme.mockLineShort
                Layout.preferredHeight: Appearance.theme.mockLineHeight

                color: root.scheme.fgMuted
                radius: height / 2
            }

            Item {
                Layout.fillHeight: true
            }

            Row {
                spacing: Appearance.theme.swatchSpacing

                Repeater {
                    model: [root.scheme.accent, root.scheme.green, root.scheme.warning, root.scheme.critical, root.scheme.magenta]

                    Rectangle {
                        required property string modelData

                        width: Appearance.theme.swatchSize
                        height: Appearance.theme.swatchSize
                        radius: width / 2
                        color: modelData
                    }
                }
            }
        }
    }

    StyledText {
        anchors.top: frame.bottom
        anchors.topMargin: Appearance.launcher.wallpaperLabelSpacing
        anchors.horizontalCenter: parent.horizontalCenter

        width: frame.width
        text: Theme.label(root.modelData)
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
