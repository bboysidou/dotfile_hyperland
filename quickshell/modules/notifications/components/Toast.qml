pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
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

    readonly property string copyText: [root.modelData.summary, Str.plain(root.modelData.body)].filter(part => part !== "").join("\n")
    readonly property bool timed: !root.modelData.critical && root.modelData.timeout > 0
    readonly property int timerReserve: root.timed ? Appearance.notif.timerThickness + Appearance.notif.timerMargin : 0

    readonly property bool present: root.grown && !root.modelData.closing
    readonly property bool collapsed: root.modelData.closing && card.opacity === 0

    property bool entered
    property bool grown
    property real progress: 1

    function keepAvatar(image: Item): void {
        const entry = root.modelData.entry;
        const path = NotifHistory.avatarPath(entry);
        if (path === "" || entry.avatarFile !== "" || !image.Window.window)
            return;

        const side = Appearance.notif.iconSize * Appearance.notif.avatarGrabScale;
        image.grabToImage(result => {
            if (result.saveToFile(path))
                NotifHistory.setAvatarFile(entry, path);
        }, Qt.size(side, side));
    }

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
                if (root.modelData.replying)
                    return;
                if (event.button === Qt.RightButton)
                    Notifs.dismissAll();
                else if (event.button === Qt.MiddleButton)
                    root.modelData.notification?.dismiss();
                else
                    Notifs.activate(root.modelData);
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

                source: root.modelData.iconSource
                avatar: root.modelData.avatar
                badge: root.modelData.badge
                tint: root.tint
                glyph: root.glyph

                onAvatarLoaded: image => root.keepAvatar(image)
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: Appearance.padding.tiny

                NotifHeading {
                    Layout.fillWidth: true

                    popup: root.modelData
                    aged: root.aged
                    copyText: root.copyText
                    interactive: root.interactive
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

                NotifProgress {
                    Layout.fillWidth: true

                    value: root.modelData.value
                }

                RowLayout {
                    visible: root.interactive && !root.modelData.replying && (root.modelData.buttons.length > 0 || root.modelData.code !== "" || root.modelData.replyable)

                    Layout.topMargin: Appearance.padding.tiny
                    spacing: Appearance.notif.actionSpacing

                    NotifChip {
                        visible: root.modelData.code !== ""
                        glyph: Notifs.copied === root.modelData.code ? Icons.check : Icons.key
                        label: Notifs.copied === root.modelData.code ? Appearance.notif.copiedLabel : Appearance.notif.codeTemplate.arg(root.modelData.code)
                        accent: true

                        onClicked: Notifs.copy(root.modelData.code)
                    }

                    NotifChip {
                        visible: root.modelData.replyable
                        label: Appearance.notif.labelReply

                        onClicked: root.modelData.startReply()
                    }

                    Repeater {
                        model: root.modelData.buttons

                        NotifAction {
                            required property var modelData

                            popup: root.modelData
                            action: modelData
                        }
                    }
                }

                NotifReply {
                    Layout.fillWidth: true
                    Layout.topMargin: Appearance.padding.tiny

                    visible: root.interactive && root.modelData.replying
                    popup: root.modelData
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
