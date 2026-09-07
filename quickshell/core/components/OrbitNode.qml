pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.enums

Item {
    id: root

    property string glyph: ""
    property string label: ""
    property string badge: ""
    property string badgeGlyph: ""
    property bool active: false
    property bool busy: false
    property bool failed: false
    property bool holdable: true
    property bool forgettable: false
    property bool confirming: false
    property color accent: Colours.accent
    property real entry: 0
    property bool draining: false

    readonly property bool linked: root.active
    readonly property alias hovered: pointer.containsMouse
    property real fill: {
        if (root.draining)
            return 0;
        return (root.active || pointer.containsMouse) ? 1 : 0;
    }

    signal activated
    signal held
    signal forgotten

    function resetConfirm(): void {
        root.confirming = false;
        countdown.stop();
    }

    function confirm(): void {
        if (!root.forgettable)
            return;

        if (root.confirming) {
            root.resetConfirm();
            root.forgotten();
        } else {
            root.confirming = true;
            countdown.restart();
        }
    }

    implicitWidth: Appearance.orbit.nodeWidth
    implicitHeight: Appearance.orbit.nodeHeight

    opacity: root.entry
    scale: root.entry
    visible: root.entry > 0
    activeFocusOnTab: true

    Keys.onReturnPressed: root.active ? root.held() : root.activated()
    Keys.onDeletePressed: root.confirm()

    Timer {
        id: countdown

        interval: Appearance.control.forgetConfirmTimeout

        onTriggered: root.confirming = false
    }

    onFillChanged: {
        if (root.draining && root.fill <= 0.001) {
            root.draining = false;
            root.held();
        }
    }

    onFailedChanged: {
        if (root.failed)
            flash.restart();
    }

    Behavior on fill {
        NumberAnimation {
            duration: root.draining ? Appearance.orbit.holdDuration : Appearance.orbit.fillDuration
            easing.type: Easing.Linear
        }
    }

    component Content: RowLayout {
        id: content

        property color tint

        spacing: Appearance.orbit.nodeSpacing

        Icon {
            id: mark

            text: root.busy ? Icons.refresh : root.glyph
            color: content.tint
            font.pixelSize: Appearance.orbit.nodeGlyphSize

            NumberAnimation on rotation {
                running: root.busy && root.visible
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: Appearance.orbit.spinPeriod

                onRunningChanged: {
                    if (!running)
                        mark.rotation = 0;
                }
            }
        }

        StyledText {
            Layout.fillWidth: true

            text: root.label
            color: content.tint
            font.pixelSize: Appearance.orbit.nodeLabelSize
            elide: Text.ElideRight
        }

        StyledText {
            visible: root.badge !== "" && !root.confirming

            text: root.badge
            color: content.tint
            font.pixelSize: Appearance.orbit.nodeBadgeSize
        }

        StyledText {
            visible: root.confirming

            text: Appearance.control.labelForgetConfirm
            color: Colours.critical
            font.pixelSize: Appearance.orbit.nodeBadgeSize
        }

        Icon {
            visible: root.badgeGlyph !== "" && !root.confirming

            text: root.badgeGlyph
            color: content.tint
            font.pixelSize: Appearance.orbit.nodeBadgeSize
        }
    }

    StyledRect {
        id: body

        anchors.fill: parent

        color: Colours.pill
        radius: Appearance.rounding.normal
        border.width: root.activeFocus ? Appearance.control.focusBorderWidth : 0
        border.color: root.accent

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: root.fill * parent.width
            radius: parent.radius
            color: root.accent
            antialiasing: true
            visible: !root.draining && width > 0
        }

        Canvas {
            id: wave

            property real phase: 0

            anchors.fill: parent

            visible: root.draining

            onPhaseChanged: if (root.draining)
                wave.requestPaint()

            onPaint: {
                const orbit = Appearance.orbit;
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                if (!root.draining)
                    return;

                const edge = root.fill * width;
                const amplitude = orbit.waveAmplitude * Math.sin(root.fill * Math.PI);

                ctx.save();
                ctx.beginPath();
                ctx.roundedRect(0, 0, width, height, body.radius, body.radius);
                ctx.clip();

                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(edge + Math.sin(wave.phase) * amplitude, 0);
                ctx.bezierCurveTo(edge + Math.cos(wave.phase) * amplitude, height / 3, edge + Math.sin(wave.phase + Math.PI) * amplitude, height * 2 / 3, edge + Math.cos(wave.phase + Math.PI) * amplitude, height);
                ctx.lineTo(0, height);
                ctx.closePath();

                ctx.fillStyle = root.accent;
                ctx.fill();
                ctx.restore();
            }

            NumberAnimation on phase {
                running: root.draining
                loops: Animation.Infinite
                from: 0
                to: Math.PI * 2
                duration: Appearance.orbit.wavePeriod
            }

            Connections {
                target: root

                function onFillChanged(): void {
                    if (root.draining)
                        wave.requestPaint();
                }
            }
        }

        Content {
            anchors.fill: parent
            anchors.leftMargin: Appearance.orbit.nodePaddingH
            anchors.rightMargin: Appearance.orbit.nodePaddingH

            tint: root.failed ? Colours.critical : Colours.text
        }

        Item {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: root.fill * parent.width
            clip: true

            Content {
                width: body.width - Appearance.orbit.nodePaddingH * 2
                height: parent.height
                x: Appearance.orbit.nodePaddingH

                tint: Colours.surface
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: parent.radius
            color: Colours.critical
            opacity: 0

            NumberAnimation on opacity {
                id: flash

                running: false
                from: Appearance.orbit.failFlashOpacity
                to: 0
                duration: Appearance.orbit.failFlashDuration
                easing.type: Easing.OutExpo
            }
        }

        StateLayer {
            id: pointer

            radius: body.radius

            onPressed: {
                root.forceActiveFocus();
                if (root.active && root.holdable)
                    root.draining = true;
            }

            onReleased: root.draining = false
            onCanceled: root.draining = false
            onExited: root.resetConfirm()

            onClicked: {
                if (!root.active)
                    root.activated();
            }
        }
    }
}
