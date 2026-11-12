pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    id: root
    property real level: 0
    property string channel: "L"
    readonly property real amplitude: Math.max(0, Math.min(1, root.level))
    implicitWidth: 252
    implicitHeight: 126
    color: "#121619"
    border.color: "#07090a"
    border.width: 2
    clip: true

    Rectangle {
        anchors.fill: parent; anchors.margins: 3
        gradient: Gradient {
            GradientStop { position: 0; color: "#c2ad74" }
            GradientStop { position: 0.20; color: "#f2e5ba" }
            GradientStop { position: 0.65; color: "#f7edcf" }
            GradientStop { position: 1; color: "#d8c694" }
        }
    }
    Canvas {
        id: scale
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const c = getContext("2d");
            c.reset();
            const cx = width * 0.50, cy = height * 1.43;
            const radius = height * 1.02;
            const start = -132 * Math.PI / 180, end = -48 * Math.PI / 180;
            const angle = t => start + (end - start) * t;
            const point = (t, r) => [cx + Math.cos(angle(t)) * r, cy + Math.sin(angle(t)) * r];
            function arc(a, b, color) {
                c.beginPath(); c.strokeStyle = color; c.lineWidth = 3;
                c.arc(cx, cy, radius, angle(a), angle(b)); c.stroke();
            }
            arc(0, 0.72, "#262820"); arc(0.72, 1, "#bf1730");
            const labels = ["20", "10", "7", "5", "3", "2", "1", "0", "1", "2", "3"];
            for (let i = 0; i < labels.length; i++) {
                const t = i / 10;
                const p = point(t, radius), q = point(t, radius + height * 0.12);
                c.strokeStyle = i > 7 ? "#b81b31" : "#24251f";
                c.lineWidth = 1.4; c.beginPath(); c.moveTo(p[0], p[1]); c.lineTo(q[0], q[1]); c.stroke();
                const pos = point(t, radius + height * 0.21);
                c.fillStyle = c.strokeStyle;
                c.font = "bold " + Math.round(height * 0.115) + "px sans-serif";
                c.textAlign = "center"; c.fillText(labels[i], pos[0], pos[1]);
                if (i < 10) {
                    const a = point(t + 0.05, radius), b = point(t + 0.05, radius + height * 0.065);
                    c.beginPath(); c.moveTo(a[0], a[1]); c.lineTo(b[0], b[1]); c.stroke();
                }
            }
            c.fillStyle = "#333329"; c.font = "bold " + Math.round(height * 0.075) + "px sans-serif";
            ["20", "40", "60", "80", "100%"].forEach((label, i) => {
                const p = point(0.07 + i * 0.16, radius - height * 0.13);
                c.fillText(label, p[0], p[1]);
            });
            c.font = "bold " + Math.round(height * 0.25) + "px sans-serif";
            c.fillStyle = "#11140f"; c.fillText("VU", width * 0.51, height * 0.83);
            c.font = "bold " + Math.round(height * 0.11) + "px sans-serif";
            c.fillText("−", width * 0.06, height * 0.21);
            c.fillStyle = "#b81b31"; c.fillText("+", width * 0.94, height * 0.21);
        }
    }
    Item {
        x: root.width * 0.50
        y: root.height * 1.43
        rotation: -42 + root.amplitude * 84
        Behavior on rotation {
            NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
        }
        Rectangle {
            x: -0.8; y: -root.height * 1.12
            width: 1.6; height: root.height * 1.12
            color: "#1a211d"
            antialiasing: true
        }
    }
    // Glass reflection, clipped to the dial.
    Rectangle {
        x: root.width * 0.09; y: -root.height * 0.4
        width: root.width * 0.24; height: root.height * 2
        rotation: 27; color: "#ffffff"; opacity: 0.09
    }
    Text {
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.margins: 6; text: root.channel; color: "#746d56"; font.pixelSize: 9
    }
}
