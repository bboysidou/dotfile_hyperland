pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

Item {
    id: root

    property var slots: []
    property color accent: Colours.accent

    readonly property var config: Appearance.weather
    readonly property real radiusX: root.width * root.config.orbitWidthRatio / 2
    readonly property real radiusY: root.height * root.config.orbitHeightRatio / 2
    readonly property real stepAngle: 360 / Math.max(1, root.slots.length)

    property real phase: 0
    readonly property int activeIndex: root.slots.findIndex(slot => slot.active)
    property real offset: root.activeIndex >= 0 ? root.config.frontAngle - root.activeIndex * root.stepAngle : root.config.orbitStartAngle

    Behavior on offset {
        Anim {
            type: AnimType.emphasized
        }
    }
    readonly property var emptySlot: ({
            hour: 0,
            glyph: "",
            temp: NaN,
            active: false
        })

    function temperature(value: real): string {
        return isNaN(value) ? "" : root.config.tempTemplate.arg(Weather.temp(value).toFixed(1));
    }

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    NumberAnimation on phase {
        running: root.visible
        loops: Animation.Infinite
        from: 0
        to: Math.PI * 2
        duration: Appearance.orbit.swayPeriod
    }

    OrbitOrbs {
        anchors.fill: parent

        angle: root.phase
        accent: root.accent
    }

    Shape {
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer
        opacity: root.config.orbitOpacity

        ShapePath {
            strokeColor: Colours.textMuted
            strokeWidth: 1
            strokeStyle: ShapePath.DashLine
            dashPattern: [root.config.orbitDash, root.config.orbitDash]
            fillColor: "transparent"

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.radiusX
                radiusY: root.radiusY
                startAngle: 0
                sweepAngle: 360
            }
        }
    }

    Column {
        anchors.centerIn: parent

        spacing: root.config.clockSpacing

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 0

            StyledText {
                Layout.alignment: Qt.AlignBaseline

                text: Qt.formatDateTime(clock.date, root.config.clockFormat)
                color: Colours.textBright
                font.pixelSize: root.config.clockSize
                font.bold: true
            }

            StyledText {
                Layout.alignment: Qt.AlignBaseline

                text: Qt.formatDateTime(clock.date, root.config.secondsFormat)
                color: root.accent
                font.pixelSize: root.config.secondsSize
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDateTime(clock.date, root.config.dateFormat)
            color: Colours.textMuted
            font.pixelSize: root.config.dateSize
        }
    }

    Repeater {
        model: root.slots.length

        ForecastPill {
            id: pill

            required property int index

            readonly property var slot: root.slots[index] ?? root.emptySlot
            readonly property real angle: (root.offset + index * root.stepAngle) * Math.PI / 180 + Math.sin(root.phase + index) * Appearance.orbit.swayAmount
            readonly property real front: Math.sin(pill.angle)

            property bool armed: false
            property real entry: pill.armed ? 1 : 0

            x: root.width / 2 + root.radiusX * Math.cos(pill.angle) * pill.entry - width / 2
            y: root.height / 2 + root.radiusY * Math.sin(pill.angle) * pill.entry - height / 2
            z: pill.slot.active ? 2 : pill.front
            opacity: pill.entry * (1 - root.config.depthFade * (1 - pill.front) / 2)
            depth: 1 + root.config.depthScale * pill.front

            Behavior on entry {
                Anim {
                    type: AnimType.defaultSpatial
                }
            }

            Timer {
                interval: Appearance.orbit.nodeEntryDelay + pill.index * Appearance.orbit.nodeEntryStep
                running: !pill.armed

                onTriggered: pill.armed = true
            }

            time: root.config.slotTimeFormat.replace("HH", String(slot.hour).padStart(2, "0"))
            glyph: slot.glyph
            temp: root.temperature(slot.temp)
            active: slot.active
            accent: root.accent
        }
    }
}
