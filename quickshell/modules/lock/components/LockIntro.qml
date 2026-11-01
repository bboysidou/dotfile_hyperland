pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config

Item {
    id: root

    property color accent: Colours.accent
    property real head: 0
    property real tail: 0
    property real bloom: 0
    property real shackle: 0
    property real punch: 1

    readonly property var lock: Appearance.lock

    signal landed
    signal finished

    function play(): void {
        timeline.stop();
        burst.reset();
        root.head = 0;
        root.tail = 0;
        root.bloom = 0;
        root.shackle = 0;
        root.punch = 1;
        timeline.start();
    }

    IntroStrands {
        anchors.fill: parent

        head: root.head
        tail: root.tail
        accent: root.accent
    }

    OrbitCore {
        anchors.centerIn: parent

        linked: true
        accent: root.accent
        visible: root.bloom > 0
        opacity: Math.min(1, root.bloom * root.lock.introOrbFade)
        scale: (root.lock.introOrbFrom + (1 - root.lock.introOrbFrom) * root.bloom) * root.punch

        content: Component {
            Padlock {
                progress: root.shackle
            }
        }
    }

    IntroBurst {
        id: burst

        anchors.centerIn: parent

        accent: root.accent
    }

    SequentialAnimation {
        id: timeline

        PauseAnimation {
            duration: root.lock.introStrandDelay
        }

        NumberAnimation {
            target: root
            property: "head"
            to: 1
            duration: root.lock.introStrandDuration
            easing.type: Easing.InOutCubic
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "bloom"
                to: 1
                duration: root.lock.introOrbDuration
                easing.type: Easing.OutBack
            }

            NumberAnimation {
                target: root
                property: "tail"
                to: 1
                duration: root.lock.introStrandRetract
                easing.type: Easing.InCubic
            }
        }

        PauseAnimation {
            duration: root.lock.introOpenHold
        }

        NumberAnimation {
            target: root
            property: "shackle"
            to: 1
            duration: root.lock.introDropDuration
            easing.type: Easing.InCubic
        }

        ScriptAction {
            script: {
                burst.fire();
                root.landed();
            }
        }

        NumberAnimation {
            target: root
            property: "punch"
            to: root.lock.introPunchScale
            duration: root.lock.introPunchOut
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: root
            property: "punch"
            to: 1
            duration: root.lock.introPunchBack
            easing.type: Easing.OutBack
        }

        PauseAnimation {
            duration: root.lock.introHold
        }

        ScriptAction {
            script: root.finished()
        }
    }
}
