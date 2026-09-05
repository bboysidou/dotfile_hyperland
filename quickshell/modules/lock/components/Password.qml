pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

Column {
    id: root

    property real shakeOffset: 0
    property bool flashing: false

    readonly property int shakeRebound: Appearance.lock.shakeAmplitude * Appearance.lock.shakeDecay

    spacing: Appearance.lock.messageTopMargin

    Connections {
        target: Lock

        function onFailed(): void {
            failure.restart();
        }
    }

    SequentialAnimation {
        id: failure

        PropertyAction {
            target: root
            property: "flashing"
            value: true
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: -Appearance.lock.shakeAmplitude
            duration: Appearance.lock.shakeStep
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: Appearance.lock.shakeAmplitude
            duration: Appearance.lock.shakeStep
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: -root.shakeRebound
            duration: Appearance.lock.shakeStep
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: root.shakeRebound
            duration: Appearance.lock.shakeStep
            easing.type: Easing.InOutQuad
        }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "shakeOffset"
                to: 0
                duration: Appearance.lock.shakeStep
                easing.type: Easing.InOutQuad
            }
            Anim {
                target: dots
                property: "opacity"
                to: 0
                type: AnimType.fastEffects
            }
            Anim {
                target: dots
                property: "scale"
                to: Appearance.lock.dotCollapseScale
                type: AnimType.fastEffects
            }
        }
        ScriptAction {
            script: Lock.recover()
        }
        PropertyAction {
            target: dots
            property: "opacity"
            value: 1
        }
        PropertyAction {
            target: dots
            property: "scale"
            value: 1
        }
        PauseAnimation {
            duration: Appearance.lock.flashHold
        }
        PropertyAction {
            target: root
            property: "flashing"
            value: false
        }
    }

    StyledRect {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.shakeOffset

        implicitWidth: Appearance.lock.fieldWidth
        implicitHeight: Appearance.lock.fieldHeight

        color: Colours.trough
        radius: Appearance.lock.fieldRounding
        border.width: Appearance.lock.fieldBorderWidth
        border.color: root.flashing ? Colours.critical : Lock.busy ? Colours.textMuted : Colours.accent
        opacity: Lock.coolingDown ? Appearance.control.disabledOpacity : 1

        Behavior on border.color {
            CAnim {
                type: AnimType.fastEffects
            }
        }

        Text {
            anchors.centerIn: parent

            visible: Lock.buffer.length === 0
            text: Appearance.lock.placeholderTemplate.arg(Lock.user)
            color: Colours.textMuted
            font.family: Appearance.lock.labelFont
            font.pixelSize: Appearance.lock.greetingFontSize
            font.weight: Appearance.lock.labelWeight
            font.italic: true
        }

        DotField {
            id: dots

            anchors.centerIn: parent

            visible: Lock.buffer.length > 0
            count: Lock.buffer.length
        }
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter

        visible: Lock.message.length > 0
        text: Lock.message
        color: Colours.critical
        font.family: Appearance.lock.labelFont
        font.pixelSize: Appearance.lock.messageFontSize
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter

        visible: Lock.failures > 0
        text: Lock.failureText
        color: Lock.coolingDown ? Colours.critical : Colours.textMuted
        font.family: Appearance.lock.labelFont
        font.pixelSize: Appearance.lock.messageFontSize
    }
}
