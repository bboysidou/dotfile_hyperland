import QtQuick
import QtQuick.Shapes
import qs.core.config

Item {
    id: root

    property real progress: 0
    property color tint: Colours.surface
    property color hole: Colours.accent

    readonly property var lock: Appearance.lock

    Item {
        id: group

        anchors.centerIn: parent

        width: root.lock.padlockBodyWidth
        height: root.lock.padlockShackleHeight + root.lock.padlockBodyHeight / 2

        Shape {
            id: shackle

            readonly property real stroke: root.lock.padlockShackleStroke
            readonly property real inset: shackle.stroke / 2
            readonly property real bend: (shackle.width - shackle.stroke) / 2

            anchors.horizontalCenter: parent.horizontalCenter

            y: -root.lock.padlockLift * (1 - root.progress)
            width: root.lock.padlockShackleWidth
            height: root.lock.padlockShackleHeight

            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: root.tint
                strokeWidth: shackle.stroke
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                startX: shackle.inset
                startY: shackle.height - shackle.inset

                PathLine {
                    x: shackle.inset
                    y: shackle.inset + shackle.bend
                }

                PathArc {
                    x: shackle.width - shackle.inset
                    y: shackle.inset + shackle.bend
                    radiusX: shackle.bend
                    radiusY: shackle.bend
                }

                PathLine {
                    x: shackle.width - shackle.inset
                    y: shackle.height - shackle.inset - root.lock.padlockLegCut
                }
            }
        }

        Rectangle {
            id: body

            anchors.bottom: parent.bottom

            width: parent.width
            height: root.lock.padlockBodyHeight
            radius: root.lock.padlockBodyRadius

            color: root.tint
            antialiasing: true

            Rectangle {
                id: keyhole

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -root.lock.padlockKeyStemHeight / 2

                width: root.lock.padlockKeyholeSize
                height: width
                radius: width / 2

                color: root.hole
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: keyhole.verticalCenter

                width: root.lock.padlockKeyStemWidth
                height: root.lock.padlockKeyStemHeight
                radius: width / 2

                color: root.hole
            }
        }
    }
}
