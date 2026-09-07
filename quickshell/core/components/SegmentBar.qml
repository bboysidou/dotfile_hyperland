pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config

Item {
    id: root

    required property var options
    property string current: ""
    property color accent: Colours.accent

    readonly property int index: Math.max(0, root.options.findIndex(option => option.key === root.current))
    readonly property real segmentWidth: root.width / Math.max(1, root.options.length)

    property real leading: root.index * root.segmentWidth
    property real trailing: (root.index + 1) * root.segmentWidth
    property real pop: 1
    property real flash: 0

    signal selected(string key)

    implicitHeight: Appearance.segment.height

    onIndexChanged: {
        const config = Appearance.segment;
        const forward = root.trailing < (root.index + 1) * root.segmentWidth;
        leadAnim.duration = forward ? config.slideSlow : config.slideFast;
        trailAnim.duration = forward ? config.slideFast : config.slideSlow;
    }

    Behavior on leading {
        NumberAnimation {
            id: leadAnim

            duration: Appearance.segment.slideFast
            easing.type: Easing.OutExpo
        }
    }

    Behavior on trailing {
        NumberAnimation {
            id: trailAnim

            duration: Appearance.segment.slideFast
            easing.type: Easing.OutExpo
        }
    }

    SequentialAnimation {
        id: popAnim

        NumberAnimation {
            target: root
            property: "pop"
            to: Appearance.segment.popScale
            duration: Appearance.segment.popIn
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "pop"
            to: 1
            duration: Appearance.segment.popOut
            easing.type: Easing.OutQuint
        }
    }

    NumberAnimation {
        id: flashAnim

        target: root
        property: "flash"
        from: Appearance.segment.flashOpacity
        to: 0
        duration: Appearance.segment.flashDuration
        easing.type: Easing.OutExpo
    }

    StyledRect {
        id: bg

        anchors.fill: parent

        radius: Appearance.segment.rounding
        color: Colours.trough
        border.width: Appearance.segment.borderWidth
        border.color: Colours.border
        clip: true
        scale: root.pop

        StyledRect {
            x: root.leading
            y: 0

            width: Math.max(0, root.trailing - root.leading)
            height: bg.height
            color: root.accent

            topLeftRadius: root.index === 0 ? Appearance.segment.rounding : Appearance.segment.innerRounding
            bottomLeftRadius: root.index === 0 ? Appearance.segment.rounding : Appearance.segment.innerRounding
            topRightRadius: root.index === root.options.length - 1 ? Appearance.segment.rounding : Appearance.segment.innerRounding
            bottomRightRadius: root.index === root.options.length - 1 ? Appearance.segment.rounding : Appearance.segment.innerRounding

            Behavior on color {
                CAnim {}
            }
        }

        RowLayout {
            anchors.fill: parent

            spacing: Appearance.spacing.none

            Repeater {
                model: root.options

                Item {
                    id: segment

                    required property var modelData
                    required property int index

                    readonly property bool active: root.index === segment.index

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StyledRect {
                        anchors.fill: parent

                        radius: Appearance.segment.innerRounding
                        color: !segment.active && pointer.containsMouse ? Colours.hover : "transparent"

                        Behavior on color {
                            CAnim {}
                        }
                    }

                    StyledText {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.segment.padding
                        anchors.rightMargin: Appearance.segment.padding

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: segment.modelData.label
                        color: segment.active ? Colours.surface : Colours.textMuted
                        font.pixelSize: Appearance.segment.fontSize
                        font.weight: segment.active ? Appearance.font.weightActive : Appearance.font.weightNormal
                        elide: Text.ElideRight

                        Behavior on color {
                            CAnim {}
                        }
                    }

                    MouseArea {
                        id: pointer

                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (segment.active)
                                return;

                            root.selected(segment.modelData.key);
                            popAnim.restart();
                            flashAnim.restart();
                        }
                    }
                }
            }
        }

        StyledRect {
            anchors.fill: parent

            radius: Appearance.segment.rounding
            color: Colours.textBright
            opacity: root.flash
        }
    }
}
