pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

Item {
    id: root

    required property Notif modelData
    property bool interactive: true

    readonly property color tint: modelData.critical ? Colours.urgencyCritical : Colours.textMuted
    readonly property string glyph: modelData.critical ? Icons.notifCritical : Icons.notifNormal
    readonly property bool aged: Time.now.getTime() - modelData.created >= Appearance.notif.ageThreshold * 1000

    readonly property bool timed: !root.modelData.critical && root.modelData.timeout > 0
    readonly property int timerReserve: root.timed ? Appearance.notif.timerThickness + Appearance.notif.timerMargin : 0

    readonly property bool present: root.grown && !root.modelData.closing
    readonly property bool collapsed: root.modelData.closing && card.opacity === 0

    property bool entered
    property bool grown
    property real progress: 1

    function sync(): void {
        countdown.stop();

        const span = root.modelData.armedFor;
        if (span <= 0) {
            root.progress = 1;
            return;
        }

        const left = Math.max(0, span - (Date.now() - root.modelData.armedAt));
        countdown.from = left / span;
        countdown.duration = left;
        countdown.restart();
    }

    Layout.fillWidth: true

    implicitWidth: Num.clamp(layout.implicitWidth + Appearance.notif.paddingH * 2, Appearance.notif.widthMin, Appearance.notif.widthMax)
    readonly property int contentHeight: Num.clamp(layout.implicitHeight + Appearance.notif.paddingV * 2 + root.timerReserve, Appearance.notif.heightMin, Appearance.notif.heightMax)

    implicitHeight: root.entered && !root.collapsed ? root.contentHeight : 0

    onImplicitHeightChanged: {
        if (root.entered && root.implicitHeight >= root.contentHeight)
            root.grown = true;
    }

    Behavior on implicitHeight {
        Anim {
            type: AnimType.standardSmall
        }
    }

    Rectangle {
        id: card

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.contentHeight

        color: root.modelData.critical ? Colours.criticalSurface : Colours.pill
        radius: Appearance.notif.rounding
        antialiasing: true
        clip: true

        opacity: root.present ? 1 : 0

        transform: Translate {
            x: root.present ? 0 : Appearance.notif.slideDistance

            Behavior on x {
                Anim {
                    type: AnimType.fastSpatial
                }
            }
        }

        Behavior on opacity {
            Anim {
                type: AnimType.fastEffects
            }
        }

        MouseArea {
            anchors.fill: parent

            enabled: root.interactive
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            hoverEnabled: true

            onEntered: root.modelData.hold(true)
            onExited: root.modelData.hold(false)

            onClicked: event => {
                if (event.button === Qt.RightButton)
                    Notifs.dismissAll();
                else if (event.button === Qt.MiddleButton && root.modelData.defaultAction)
                    root.modelData.invoke(root.modelData.defaultAction);
                else
                    root.modelData.notification?.dismiss();
            }
        }

        RowLayout {
            id: layout

            anchors.fill: parent
            anchors.leftMargin: Appearance.notif.paddingH
            anchors.rightMargin: Appearance.notif.paddingH
            anchors.topMargin: Appearance.notif.paddingV
            anchors.bottomMargin: Appearance.notif.paddingV + root.timerReserve

            spacing: Appearance.notif.iconSpacing

            NotifIcon {
                Layout.alignment: Qt.AlignTop

                popup: root.modelData
                tint: root.tint
                glyph: root.glyph
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: Appearance.padding.tiny

                RowLayout {
                    Layout.fillWidth: true

                    spacing: Appearance.spacing.small

                    ScrollText {
                        Layout.fillWidth: true

                        text: root.modelData.summary
                        color: root.modelData.critical ? Colours.urgencyCritical : Colours.textBright
                        font.weight: Appearance.font.weightActive
                    }

                    StyledText {
                        visible: root.aged

                        text: Fmt.age(root.modelData.created, Time.now)
                        color: Colours.textMuted
                        font.pixelSize: Appearance.font.size.tiny
                        font.weight: Appearance.font.weightIcon
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    visible: text !== ""
                    text: Fmt.markup(root.modelData.body)
                    textFormat: Text.StyledText
                    color: Colours.text
                    font.weight: Appearance.font.weightIcon
                    wrapMode: Text.Wrap
                    verticalAlignment: Text.AlignTop
                    elide: Text.ElideRight
                }

                ClippingRectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: Appearance.padding.tiny

                    visible: root.modelData.preview !== ""
                    implicitHeight: Appearance.notif.previewHeight

                    color: Colours.trough
                    radius: Appearance.notif.previewRounding

                    Image {
                        anchors.fill: parent

                        source: root.modelData.preview
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: Appearance.notif.previewSourceWidth
                    }
                }

                RowLayout {
                    visible: root.interactive && root.modelData.buttons.length > 0

                    Layout.topMargin: Appearance.padding.tiny
                    spacing: Appearance.notif.actionSpacing

                    Repeater {
                        model: root.modelData.buttons

                        NotifAction {
                            required property var modelData

                            popup: root.modelData
                            action: modelData
                        }
                    }
                }
            }
        }

        Meter {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: Appearance.notif.paddingH
            anchors.rightMargin: Appearance.notif.paddingH
            anchors.bottomMargin: Appearance.notif.timerMargin

            visible: root.timed
            thickness: Appearance.notif.timerThickness
            minFill: 0
            value: root.progress
            fillColour: Colours.accent
        }
    }

    NumberAnimation {
        id: countdown

        target: root
        property: "progress"
        to: 0
    }

    Connections {
        target: root.modelData

        function onArmedAtChanged(): void {
            root.sync();
        }

        function onArmedForChanged(): void {
            root.sync();
        }
    }

    Component.onCompleted: {
        root.entered = true;
        root.sync();
    }
}
