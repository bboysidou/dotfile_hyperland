pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    id: root
    property bool spinning: false
    property real tape: 0.5
    width: 56
    height: width
    radius: width / 2
    color: "#0d1010"
    border.color: "#84847e"
    border.width: width * 0.04

    Item {
        id: wheel
        anchors.fill: parent
        NumberAnimation on rotation {
            from: 0; to: 360; duration: 2600; loops: Animation.Infinite
            running: true; paused: !root.spinning
        }
        Repeater {
            model: 6
            Item {
                required property int index
                anchors.fill: parent
                rotation: index * 60
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: root.width * 0.07
                    width: root.width * 0.14
                    height: root.width * 0.19
                    radius: 1
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#f2f0e5" }
                        GradientStop { position: 1; color: "#8b8c85" }
                    }
                }
            }
        }
        Rectangle {
            anchors.centerIn: parent
            width: root.width * 0.57; height: width; radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0; color: "#777a73" }
                GradientStop { position: 0.45; color: "#303632" }
                GradientStop { position: 1; color: "#151a17" }
            }
            border.color: "#242a25"; border.width: 2
            Rectangle {
                anchors.centerIn: parent
                width: root.width * 0.30; height: width; radius: width / 2
                color: "#bfc1b8"; border.color: "#72776f"; border.width: 2
                Rectangle {
                    anchors.centerIn: parent
                    width: root.width * 0.14; height: width; radius: width / 2
                    color: "#393e37"
                }
            }
        }
    }
}
