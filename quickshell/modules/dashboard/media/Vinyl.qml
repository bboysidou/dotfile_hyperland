import QtQuick
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

Item {
    id: root

    property bool active: true

    property int coverSize: Appearance.dash.vinylSize
    property real magnitude: Appearance.dash.visualiserMagnitude
    property int labelSize: Appearance.dash.vinylLabelSize

    readonly property real ringRadius: root.coverSize / 2 + Appearance.dash.visualiserGap

    implicitWidth: (root.ringRadius + Appearance.dash.visualiserMinBar + root.magnitude) * 2
    implicitHeight: root.implicitWidth

    Visualiser {
        anchors.fill: parent

        active: root.active
        innerRadius: root.ringRadius
        magnitude: root.magnitude
        colour: Colours.media
    }

    ClippingRectangle {
        id: cover

        anchors.centerIn: parent

        width: root.coverSize
        height: root.coverSize
        radius: width / 2
        color: Colours.trough

        Icon {
            anchors.centerIn: parent

            text: Icons.album
            color: Colours.textMuted
            font.pixelSize: root.labelSize
            visible: art.status !== Image.Ready
        }

        Image {
            id: art

            anchors.fill: parent

            source: Players.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: root.coverSize * 2
            sourceSize.height: root.coverSize * 2
            opacity: art.status === Image.Ready ? 1 : 0

            Behavior on opacity {
                Anim {
                    type: AnimType.defaultEffects
                }
            }
        }

        RotationAnimation on rotation {
            running: Players.playing && root.visible && root.active
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: Appearance.dash.vinylSpinDuration
            easing.type: Easing.Linear
        }
    }

    StyledRect {
        anchors.centerIn: parent

        width: Appearance.dash.visualiserGap
        height: width
        radius: width / 2
        color: Colours.bar
    }
}
