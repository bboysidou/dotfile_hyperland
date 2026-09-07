pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.enums

Item {
    id: root

    property Component content: null

    property bool powered: true
    property bool available: true
    property bool linked: false
    property color accent: Colours.accent
    property string glyph: ""

    readonly property bool searching: root.powered && root.available && !root.linked

    implicitWidth: Appearance.orbit.coreSize
    implicitHeight: Appearance.orbit.coreSize

    Elevation {
        anchors.fill: body

        level: root.powered ? Appearance.elevation.panel : 0
        radius: body.radius
        z: -1
    }

    Rectangle {
        id: glow

        property real breath: 1

        anchors.centerIn: body

        width: body.width + Appearance.orbit.glowInset
        height: width
        radius: width / 2

        color: root.accent
        opacity: root.linked ? Appearance.orbit.glowOpacity : 0
        scale: glow.breath
        z: -2

        Behavior on opacity {
            Anim {
                type: AnimType.slowEffects
            }
        }

        SequentialAnimation on breath {
            running: root.visible && root.linked
            loops: Animation.Infinite

            NumberAnimation {
                to: Appearance.orbit.glowScale
                duration: Appearance.orbit.glowPeriod
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1
                duration: Appearance.orbit.glowPeriod
                easing.type: Easing.InOutSine
            }
        }
    }

    Rectangle {
        id: pulse

        property real swing: Appearance.orbit.pulseBaseOpacity
        property real breath: Appearance.orbit.pulseBaseScale

        anchors.centerIn: body

        width: body.width + Appearance.orbit.pulseInset
        height: width
        radius: width / 2

        color: "transparent"
        border.color: root.accent
        border.width: Appearance.orbit.pulseWidth

        opacity: root.linked ? pulse.swing : 0
        scale: pulse.breath
        z: -3

        Timer {
            interval: Appearance.orbit.pulseInterval
            running: root.visible && root.linked
            repeat: true

            onTriggered: {
                const orbit = Appearance.orbit;
                const time = Date.now() / 1000;

                pulse.swing = orbit.pulseBaseOpacity + Math.sin(time * orbit.pulseOpacityRate) * orbit.pulseSwingOpacity;
                pulse.breath = orbit.pulseBaseScale + Math.cos(time * orbit.pulseScaleRate) * orbit.pulseSwingScale;
            }
        }
    }

    Rectangle {
        id: body

        anchors.fill: parent

        radius: width / 2
        antialiasing: true
        border.width: Appearance.orbit.coreBorderWidth
        border.color: root.linked ? Qt.lighter(root.accent, Appearance.orbit.coreBorderHighlight) : Colours.border

        Behavior on border.color {
            CAnim {}
        }

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop {
                position: 0
                color: root.linked ? Qt.lighter(root.accent, Appearance.orbit.coreHighlight) : Colours.trough

                Behavior on color {
                    CAnim {}
                }
            }

            GradientStop {
                position: 1
                color: root.linked ? root.accent : Colours.surface

                Behavior on color {
                    CAnim {}
                }
            }
        }

        Item {
            anchors.fill: parent

            opacity: root.searching ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                Anim {}
            }

            Repeater {
                model: Appearance.orbit.rippleCount

                Rectangle {
                    id: ripple

                    required property int index

                    anchors.centerIn: parent

                    width: parent.width * Appearance.orbit.rippleRatio
                    height: width
                    radius: width / 2

                    color: "transparent"
                    border.color: root.accent
                    border.width: Appearance.orbit.rippleWidth

                    SequentialAnimation on scale {
                        running: root.visible && root.searching
                        loops: Animation.Infinite

                        PauseAnimation {
                            duration: ripple.index * Appearance.orbit.rippleStagger
                        }

                        NumberAnimation {
                            from: 1
                            to: Appearance.orbit.rippleScaleTo
                            duration: Appearance.orbit.ripplePeriod
                            easing.type: Easing.OutSine
                        }
                    }

                    SequentialAnimation on opacity {
                        running: root.visible && root.searching
                        loops: Animation.Infinite

                        PauseAnimation {
                            duration: ripple.index * Appearance.orbit.rippleStagger
                        }

                        NumberAnimation {
                            from: Appearance.orbit.rippleOpacityFrom
                            to: 0
                            duration: Appearance.orbit.ripplePeriod
                            easing.type: Easing.OutSine
                        }
                    }
                }
            }
        }

        Item {
            id: glyphHolder

            property real pulse: 1

            anchors.fill: parent

            opacity: root.linked ? 0 : (root.searching ? glyphHolder.pulse : 1)
            visible: opacity > 0

            SequentialAnimation on pulse {
                running: root.visible && root.searching
                loops: Animation.Infinite

                NumberAnimation {
                    to: Appearance.orbit.glyphPulseOpacity
                    duration: Appearance.orbit.glyphPulsePeriod
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 1
                    duration: Appearance.orbit.glyphPulsePeriod
                    easing.type: Easing.InOutSine
                }
            }

            Icon {
                anchors.centerIn: parent

                text: root.glyph
                color: root.powered ? root.accent : Colours.textMuted
                font.pixelSize: Appearance.orbit.coreGlyphSize
            }
        }

        Loader {
            anchors.fill: parent

            active: root.content !== null
            sourceComponent: root.content
            opacity: root.linked ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                Anim {}
            }
        }
    }
}
