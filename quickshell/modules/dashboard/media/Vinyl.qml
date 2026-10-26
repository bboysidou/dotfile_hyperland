import QtQuick
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

Item {
    id: root

    property bool active: true
    property color accent: Colours.media

    property int coverSize: Appearance.dash.vinylSize
    property real magnitude: Appearance.dash.visualiserMagnitude

    readonly property real ringRadius: root.coverSize / 2 + Appearance.dash.visualiserGap
    readonly property real discSize: root.coverSize / Appearance.dash.vinylDiscRatio
    readonly property real labelSize: root.discSize * Appearance.dash.vinylLabelRatio

    implicitWidth: (root.ringRadius + Appearance.dash.visualiserMinBar + root.magnitude) * 2
    implicitHeight: root.implicitWidth

    Visualiser {
        anchors.fill: parent

        active: root.active
        innerRadius: root.ringRadius
        magnitude: root.magnitude
        colour: root.accent
    }

    Item {
        id: cover

        anchors.centerIn: parent

        width: root.coverSize
        height: root.coverSize

        Image {
            x: cover.width / 2 - root.discSize * Appearance.dash.vinylLabelX
            y: cover.height / 2 - root.discSize * Appearance.dash.vinylLabelY
            width: root.discSize
            height: root.discSize

            source: Paths.vinyl
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            mipmap: true
            sourceSize.width: root.discSize * 2
            sourceSize.height: root.discSize * 2
        }

        ClippingRectangle {
            anchors.centerIn: parent

            width: root.labelSize
            height: root.labelSize
            radius: width / 2
            color: "transparent"
            opacity: Players.available && art.status === Image.Ready ? 1 : 0

            Behavior on opacity {
                Anim {
                    type: AnimType.defaultEffects
                }
            }

            Image {
                id: art

                anchors.fill: parent

                source: Players.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: root.labelSize * 2
                sourceSize.height: root.labelSize * 2
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
