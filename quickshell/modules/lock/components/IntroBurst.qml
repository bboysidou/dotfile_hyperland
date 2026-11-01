pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config

Item {
    id: root

    property real progress: 0
    property real flash: 0
    property color accent: Colours.accent

    readonly property var lock: Appearance.lock
    readonly property real base: Appearance.orbit.coreSize

    function fire(): void {
        wave.restart();
    }

    function reset(): void {
        wave.stop();
        root.progress = 0;
        root.flash = 0;
    }

    width: root.base
    height: root.base

    ParallelAnimation {
        id: wave

        NumberAnimation {
            target: root
            property: "progress"
            from: 0
            to: 1
            duration: root.lock.introBurstDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "flash"
            from: root.lock.introFlashOpacity
            to: 0
            duration: root.lock.introFlashDuration
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        anchors.centerIn: parent

        width: root.base
        height: width
        radius: width / 2

        color: Colours.textBright
        opacity: root.flash
    }

    Repeater {
        model: root.lock.introRingCount

        Rectangle {
            id: ring

            required property int index

            readonly property real offset: ring.index * root.lock.introRingStagger
            readonly property real local: Math.max(0, Math.min(1, (root.progress - ring.offset) / (1 - ring.offset)))

            anchors.centerIn: parent

            width: root.base + ring.local * root.lock.introRingGrow
            height: width
            radius: width / 2

            color: "transparent"
            border.color: ring.index === 0 ? Colours.textBright : root.accent
            border.width: Math.max(1, root.lock.introRingWidth * (1 - ring.local))
            opacity: ring.local > 0 ? root.lock.introRingOpacity * (1 - ring.local) : 0
        }
    }

    Repeater {
        model: root.lock.introSparkCount

        Rectangle {
            id: spark

            required property int index

            readonly property real angle: (spark.index + (spark.index % 2) * root.lock.introSparkJitter) / root.lock.introSparkCount * Math.PI * 2
            readonly property real distance: root.base / 2 + root.lock.introSparkReach * root.progress

            x: root.width / 2 + Math.cos(spark.angle) * spark.distance - spark.width / 2
            y: root.height / 2 + Math.sin(spark.angle) * spark.distance - spark.height / 2
            width: root.lock.introSparkLength * (1 - root.progress)
            height: root.lock.introSparkThickness
            radius: height / 2
            rotation: spark.angle * 180 / Math.PI

            color: spark.index % 2 === 0 ? Colours.textBright : root.accent
            opacity: root.progress > 0 ? 1 - root.progress : 0
            antialiasing: true
        }
    }
}
