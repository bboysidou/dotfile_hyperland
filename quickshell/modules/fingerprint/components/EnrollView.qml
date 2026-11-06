import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.display.components
import qs.modules.fingerprint
import qs.services

ColumnLayout {
    id: root

    readonly property var config: Appearance.fingerprint
    readonly property bool done: FingerprintEnroll.phase === FingerprintPhase.done
    readonly property bool failed: FingerprintEnroll.phase === FingerprintPhase.failed

    property real shakeOffset: 0
    property bool flashing: false

    readonly property string text: {
        if (root.done)
            return root.config.messageDone;
        if (FingerprintEnroll.message)
            return FingerprintEnroll.message;

        return FingerprintEnroll.stage > 0 ? root.config.promptAgain : root.config.promptTouch;
    }

    spacing: root.config.viewSpacing

    Connections {
        target: FingerprintEnroll

        function onRetried(): void {
            retry.restart();
        }

        function onPhaseChanged(): void {
            if (root.done)
                pop.restart();
        }
    }

    SequentialAnimation {
        id: retry

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

    SequentialAnimation {
        id: pop

        NumberAnimation {
            target: glyph
            property: "scale"
            to: root.config.glyphPopScale
            duration: root.config.glyphPopDuration
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: glyph
            property: "scale"
            to: 1
            duration: root.config.glyphPopDuration
            easing.type: Easing.InOutQuad
        }
    }

    FingerprintGlyph {
        id: glyph

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.config.glyphSize
        Layout.preferredHeight: root.config.glyphSize

        progress: FingerprintEnroll.progress
        regions: FingerprintEnroll.total
        fillColour: root.flashing || root.failed ? Colours.critical : Colours.accent

        transform: Translate {
            x: root.shakeOffset
        }
    }

    StyledText {
        Layout.fillWidth: true

        text: root.text
        color: root.flashing || root.failed ? Colours.critical : Colours.textBright
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: root.config.messageSize
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter

        visible: FingerprintEnroll.stages > 0 && !root.done
        text: root.config.stageTemplate.arg(FingerprintEnroll.stage).arg(FingerprintEnroll.stages)
        color: Colours.textMuted
        font.pixelSize: root.config.countSize
    }

    Row {
        Layout.alignment: Qt.AlignHCenter

        visible: !root.done
        spacing: root.config.chipSpacing

        Chip {
            visible: root.failed

            label: root.config.labelRetry
            active: true

            onTriggered: FingerprintEnroll.start(FingerprintEnroll.finger)
        }

        Chip {
            label: root.config.labelCancel

            onTriggered: FingerprintState.closeEnroll()
        }
    }
}
