import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.fingerprint.components
import qs.services

Item {
    id: root

    readonly property var config: Appearance.lock

    property real fill: 0
    property real shakeOffset: 0
    property bool flashing: false
    property real ripplePhase: 0

    readonly property bool rippling: root.visible && root.fill === 0 && !root.flashing && !Lock.unlocking

    function run(target: real, duration: int, easing: int): void {
        rise.stop();
        rise.to = target;
        rise.duration = duration;
        rise.easing.type = easing;
        rise.start();
    }

    implicitWidth: root.config.orbSize
    implicitHeight: root.config.orbSize

    transform: Translate {
        x: root.shakeOffset
    }

    Connections {
        target: Fingerprint

        function onReadingChanged(): void {
            if (Fingerprint.reading)
                root.run(root.config.readFillCap, Fingerprint.readEstimate, Easing.OutQuad);
        }

        function onMatched(): void {
            root.run(1, root.config.readFillFinish, Easing.OutQuad);
        }

        function onRejected(): void {
            refuse.restart();
            root.run(0, root.config.readDrain * 2, Easing.InQuad);
        }

        function onAbandoned(): void {
            root.run(0, root.config.readDrain, Easing.InOutQuad);
        }
    }

    Connections {
        target: Lock

        function onLockedChanged(): void {
            rise.stop();
            root.fill = 0;
        }
    }

    NumberAnimation on ripplePhase {
        running: root.rippling
        loops: Animation.Infinite
        from: 0
        to: 1
        duration: root.config.orbRipplePeriod
    }

    NumberAnimation {
        id: rise

        target: root
        property: "fill"
    }

    SequentialAnimation {
        id: refuse

        PropertyAction {
            target: root
            property: "flashing"
            value: true
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: -root.config.shakeAmplitude
            duration: root.config.shakeStep
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: root.config.shakeAmplitude
            duration: root.config.shakeStep
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 0
            duration: root.config.shakeStep
        }
        PauseAnimation {
            duration: root.config.flashHold
        }
        PropertyAction {
            target: root
            property: "flashing"
            value: false
        }
    }

    OrbitCore {
        anchors.fill: parent

        available: false
        linked: Lock.unlocking && root.fill >= 1
    }

    Repeater {
        model: root.config.orbRippleCount

        Rectangle {
            id: ripple

            required property int index

            readonly property real progress: (root.ripplePhase + ripple.index / root.config.orbRippleCount) % 1

            anchors.centerIn: parent

            width: root.config.orbRippleSize
            height: width
            radius: width / 2

            color: "transparent"
            border.color: Colours.accent
            border.width: root.config.orbRippleWidth
            scale: 1 + (root.config.orbRippleScale - 1) * ripple.progress
            opacity: root.rippling ? root.config.orbRippleOpacity * (1 - ripple.progress) : 0
        }
    }

    FingerprintGlyph {
        anchors.centerIn: parent

        width: root.config.orbGlyphSize
        height: root.config.orbGlyphSize

        progress: 1
        stroke: root.config.orbGlyphStroke
        centreRatio: root.config.orbGlyphCentre
        baseColour: root.flashing ? Colours.critical : Colours.accent
        fillColour: root.flashing ? Colours.critical : Colours.accent
    }

    Item {
        id: mask

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: root.fill * root.height
        clip: true

        Rectangle {
            x: 0
            y: mask.height - root.height

            width: root.width
            height: root.height
            radius: width / 2
            antialiasing: true
            color: root.flashing ? Colours.critical : Colours.accent

            FingerprintGlyph {
                anchors.centerIn: parent

                width: root.config.orbGlyphSize
                height: root.config.orbGlyphSize

                progress: 1
                stroke: root.config.orbGlyphStroke
                centreRatio: root.config.orbGlyphCentre
                baseColour: Colours.surface
                fillColour: Colours.surface
            }
        }
    }
}
