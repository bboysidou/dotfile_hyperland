pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config

Item {
    id: root

    required property var screen
    property bool focused: false

    signal revealed
    signal exited

    function leave(): void {
        enter.stop();
        reveal.stop();
        exit.start();
    }

    opacity: 0

    Component.onCompleted: intro.play()

    Anim {
        id: enter

        target: root
        property: "opacity"
        to: 1
        type: Appearance.lock.fadeInType
        duration: Appearance.lock.fadeInDuration
        running: true
    }

    SequentialAnimation {
        id: reveal

        ParallelAnimation {
            Anim {
                target: content
                property: "opacity"
                to: 1
                type: Appearance.lock.fadeInType
                duration: Appearance.lock.fadeInDuration
            }

            Anim {
                target: intro
                property: "opacity"
                to: 0
                type: Appearance.lock.fadeOutType
                duration: Appearance.lock.fadeInDuration
            }
        }

        ScriptAction {
            script: root.revealed()
        }
    }

    SequentialAnimation {
        id: exit

        Anim {
            target: root
            property: "opacity"
            to: 0
            type: Appearance.lock.fadeOutType
            duration: Appearance.lock.fadeOutDuration
        }

        ScriptAction {
            script: root.exited()
        }
    }

    LockBackdrop {
        anchors.fill: parent

        screen: root.screen
    }

    LockIntro {
        id: intro

        anchors.fill: parent

        visible: opacity > 0

        onFinished: reveal.start()
    }

    LockContent {
        id: content

        anchors.fill: parent

        focused: root.focused
        opacity: 0
        visible: opacity > 0
    }
}
