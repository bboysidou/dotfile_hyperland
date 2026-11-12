pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    property bool playing: false
    property real progress: 0
    width: 560
    height: width * 780 / 1185
    clip: true

    // Keep the supplied photograph intact; show only its cassette section.
    Image {
        width: root.width
        height: width * 1280 / 1185
        y: -500 * root.width / 1185
        source: "assets/c60-reference.jpeg"
        smooth: true
    }

    Reel {
        x: root.width * 298 / 1185
        y: root.width * 288 / 1185
        width: root.width * 114 / 1185
        spinning: root.playing
        tape: 1 - root.progress
    }
    Reel {
        x: root.width * 775 / 1185
        y: root.width * 288 / 1185
        width: root.width * 114 / 1185
        spinning: root.playing
        tape: root.progress
    }
    Rectangle {
        x: root.width * 478 / 1185
        y: root.width * 330 / 1185
        width: root.width * 227 / 1185
        height: root.width * 30 / 1185
        color: "#494940"
        clip: true
        gradient: Gradient {
            GradientStop { position: 0; color: "#34372f" }
            GradientStop { position: 0.5; color: "#7b7964" }
            GradientStop { position: 1; color: "#42453c" }
        }
        Rectangle {
            x: (parent.width - width) * Math.max(0, Math.min(1, root.progress))
            width: parent.width * 0.28
            height: parent.height
            color: "#ce993f"
            opacity: 0.85
        }
    }
}
