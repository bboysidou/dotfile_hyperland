pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.enums

Item {
    id: root

    property alias coreContent: core.content

    property var nodes: []
    property var pinned: []
    property bool powered: true
    property bool available: true
    property bool linked: false
    property bool draining: false
    property string glyph: ""
    property color accent: Colours.accent

    readonly property var entries: root.nodes.concat(root.pinned)
    readonly property bool live: root.powered && root.available
    readonly property bool animated: root.visible && (root.live || root.linked)
    property real drift: root.powered ? 0 : Appearance.orbit.nodeDriftDistance

    property real phase: 0

    signal nodeActivated(var source)
    signal nodeHeld(var source)
    signal nodeForgotten(var source)
    signal powerToggled(bool value)

    implicitHeight: Appearance.orbit.stageHeight

    NumberAnimation on phase {
        running: root.animated
        loops: Animation.Infinite
        from: 0
        to: Math.PI * 2
        duration: Appearance.orbit.swayPeriod
    }

    Behavior on drift {
        Anim {
            type: AnimType.slowEffects
        }
    }

    OrbitOrbs {
        anchors.fill: parent

        angle: root.phase
        powered: root.live || root.linked
        danger: root.draining
        accent: root.accent
    }

    Item {
        anchors.fill: parent

        Repeater {
            model: Appearance.orbit.radarCount

            Rectangle {
                id: radar

                required property int index

                anchors.centerIn: parent

                width: Appearance.orbit.radarBase + radar.index * Appearance.orbit.radarStep
                height: width
                radius: width / 2

                color: "transparent"
                border.color: root.accent
                border.width: 1

                opacity: {
                    const orbit = Appearance.orbit;
                    if (!root.powered || !root.available)
                        return orbit.radarIdleOpacity;
                    return root.linked ? orbit.radarOpacity - radar.index * orbit.radarFalloff : orbit.radarIdleOpacity;
                }

                Behavior on opacity {
                    Anim {
                        type: AnimType.slowEffects
                    }
                }
            }
        }

        OrbitStrands {
            anchors.fill: parent

            origin: core
            source: satellites
            accent: root.accent
            active: root.animated
        }

        OrbitCore {
            id: core

            anchors.centerIn: parent

            powered: root.powered
            available: root.available
            linked: root.linked
            accent: root.accent
            glyph: root.glyph

            opacity: root.powered || root.linked ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.anim.durations.orbitCore
                    easing.type: Easing.OutExpo
                }
            }
        }

        Repeater {
            id: satellites

            model: root.entries.length

            OrbitNode {
                id: slot

                required property int index

                readonly property var modelData: root.entries[slot.index] ?? ({})

                readonly property bool anchored: slot.index >= root.nodes.length
                readonly property real base: {
                    if (slot.anchored)
                        return Appearance.orbit.pinnedAngle;
                    return slot.index / Math.max(1, root.nodes.length) * Math.PI * 2;
                }
                readonly property real angle: slot.base + Math.sin(root.phase + slot.index) * Appearance.orbit.swayAmount
                readonly property real spanY: {
                    const orbit = Appearance.orbit;
                    if (slot.anchored)
                        return orbit.radiusYInner;
                    return slot.index % orbit.rings === 0 ? orbit.radiusYInner : orbit.radiusYOuter;
                }

                property bool armed: false

                x: (parent.width - width) / 2 + Math.cos(slot.angle) * (Appearance.orbit.radiusX + root.drift) * slot.entry
                y: (parent.height - height) / 2 + Math.sin(slot.angle) * (slot.spanY + root.drift) * slot.entry

                glyph: slot.modelData.glyph ?? ""
                label: slot.modelData.label ?? ""
                badge: slot.modelData.badge ?? ""
                badgeGlyph: slot.modelData.badgeGlyph ?? ""
                active: slot.modelData.active ?? false
                busy: slot.modelData.busy ?? false
                failed: slot.modelData.failed ?? false
                holdable: slot.modelData.holdable ?? true
                forgettable: slot.modelData.forgettable ?? false
                accent: root.accent

                entry: (slot.anchored || root.live) && slot.armed ? 1 : 0

                onDrainingChanged: root.draining = slot.draining
                onActivated: root.nodeActivated(slot.modelData.source)
                onHeld: root.nodeHeld(slot.modelData.source)
                onForgotten: root.nodeForgotten(slot.modelData.source)

                Behavior on entry {
                    Anim {
                        type: AnimType.defaultSpatial
                    }
                }

                Timer {
                    interval: Appearance.orbit.nodeEntryDelay + slot.index * Appearance.orbit.nodeEntryStep
                    running: (slot.anchored || root.live) && !slot.armed

                    onTriggered: slot.armed = true
                }

                Connections {
                    target: root

                    function onPoweredChanged(): void {
                        if (!root.powered && !slot.anchored)
                            slot.armed = false;
                    }
                }
            }
        }
    }

    Item {
        id: power

        property real morph: root.powered || root.linked ? 1 : 0
        readonly property real span: Appearance.orbit.powerRestSize + (Appearance.orbit.powerDockSize - Appearance.orbit.powerRestSize) * power.morph

        width: power.span
        height: power.span

        x: {
            const orbit = Appearance.orbit;
            const rest = (root.width - orbit.powerRestSize) / 2;
            const dock = root.width - orbit.powerDockMargin - orbit.powerDockSize;
            return rest + (dock - rest) * power.morph;
        }

        y: {
            const orbit = Appearance.orbit;
            const rest = (root.height - orbit.powerRestSize) / 2;
            const dock = root.height - orbit.powerDockMargin - orbit.powerDockSize;
            return rest + (dock - rest) * power.morph;
        }

        visible: root.available
        z: 1

        Behavior on morph {
            NumberAnimation {
                duration: Appearance.anim.durations.orbitMorph
                easing.type: Easing.InOutQuint
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: width / 2
            antialiasing: true

            color: root.powered ? root.accent : Colours.trough
            border.width: 1
            border.color: root.powered ? Qt.lighter(root.accent, Appearance.orbit.coreBorderHighlight) : Colours.border
            scale: pointer.pressed ? Appearance.orbit.powerPressScale : (pointer.containsMouse ? Appearance.orbit.powerHoverScale : 1)

            Behavior on color {
                CAnim {}
            }

            Behavior on scale {
                Anim {
                    type: AnimType.fastEffects
                }
            }

            Icon {
                anchors.centerIn: parent

                text: Icons.power
                color: root.powered ? Colours.surface : Colours.textMuted
                font.pixelSize: Appearance.orbit.powerRestGlyphSize + (Appearance.orbit.powerDockGlyphSize - Appearance.orbit.powerRestGlyphSize) * power.morph
            }

            StateLayer {
                id: pointer

                radius: parent.radius

                onClicked: root.powerToggled(!root.powered)
            }
        }
    }


}
