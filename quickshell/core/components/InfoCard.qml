pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    property string glyph: ""
    property string title: ""
    property string detail: ""
    property string badge: ""
    property string badgeGlyph: ""
    property bool active: false
    property bool forgettable: false
    property int position: 0
    property color accent: Colours.accent
    property var details: []
    property bool expanded: false
    property Component expansion: null

    property bool confirming: false
    property bool entered: false

    readonly property color onCard: root.active ? Colours.surface : Colours.textBright
    readonly property color onCardMuted: root.active ? Colours.surface : Colours.textMuted

    readonly property alias expansionItem: expansion.item

    signal activated
    signal forgotten
    signal expansionReady

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

    Layout.fillWidth: true
    Layout.preferredHeight: body.implicitHeight + Appearance.card.paddingV * 2

    color: root.active ? root.accent : (pointer.containsMouse ? Colours.hover : Colours.pill)
    radius: Appearance.card.rounding
    border.width: root.active ? Appearance.card.activeBorderWidth : Appearance.card.borderWidth
    border.color: root.active ? root.accent : Colours.border

    activeFocusOnTab: true
    opacity: root.entered ? 1 : 0

    Keys.onReturnPressed: root.activated()
    Keys.onDeletePressed: root.confirm()

    onVisibleChanged: {
        if (!root.visible)
            root.entered = false;
    }

    transform: Translate {
        y: root.entered ? 0 : Appearance.card.lift

        Behavior on y {
            NumberAnimation {
                duration: Appearance.card.enterDuration
                easing.type: Easing.OutQuint
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.card.enterDuration
            easing.type: Easing.OutQuint
        }
    }

    Behavior on Layout.preferredHeight {
        Anim {
            type: AnimType.emphasizedSmall
        }
    }

    Behavior on color {
        CAnim {}
    }

    Timer {
        id: countdown

        interval: Appearance.control.forgetConfirmTimeout

        onTriggered: root.confirming = false
    }

    Timer {
        running: root.visible
        interval: Appearance.card.staggerBase + root.position * Appearance.card.staggerStep

        onTriggered: root.entered = true
    }

    StateLayer {
        id: pointer

        radius: parent.radius

        onClicked: root.activated()
        onExited: root.resetConfirm()
    }

    ColumnLayout {
        id: body

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Appearance.card.paddingH
        anchors.rightMargin: Appearance.card.paddingH

        spacing: Appearance.card.spacing

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.card.spacing

            Icon {
                text: root.glyph
                color: root.active ? Colours.surface : root.accent
                font.pixelSize: Appearance.card.iconSize
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: Appearance.card.textSpacing

                StyledText {
                    Layout.fillWidth: true

                    text: root.title
                    color: root.onCard
                    font.pixelSize: Appearance.card.nameSize
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true

                    visible: root.detail !== ""
                    text: root.detail
                    color: root.onCardMuted
                    font.pixelSize: Appearance.card.detailSize
                    font.weight: Appearance.font.weightIcon
                    elide: Text.ElideMiddle
                }
            }

            StyledText {
                visible: root.badge !== "" && !root.confirming

                text: root.badge
                color: root.onCardMuted
                font.pixelSize: Appearance.card.detailSize
            }

            Icon {
                visible: root.badgeGlyph !== "" && !root.confirming

                text: root.badgeGlyph
                color: root.onCardMuted
                font.pixelSize: Appearance.card.iconSize
            }

            StyledText {
                visible: root.confirming

                text: Appearance.control.labelForgetConfirm
                color: Colours.critical
                font.pixelSize: Appearance.card.detailSize
            }

            Icon {
                visible: root.forgettable && (pointer.containsMouse || root.confirming)

                text: Icons.forget
                color: root.confirming ? Colours.critical : root.onCardMuted
                font.pixelSize: Appearance.card.iconSize

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.confirm()
                }
            }
        }

        Loader {
            id: expansion

            Layout.fillWidth: true
            Layout.topMargin: Appearance.card.spacing

            active: root.expanded && root.expansion !== null
            sourceComponent: root.expansion
            visible: active

            onLoaded: root.expansionReady()
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.card.textSpacing

            visible: root.details.length > 0
            spacing: Appearance.card.textSpacing

            Repeater {
                model: root.details

                RowLayout {
                    id: entry

                    required property var modelData

                    Layout.fillWidth: true

                    spacing: Appearance.card.spacing

                    StyledText {
                        Layout.preferredWidth: Appearance.card.detailLabelWidth

                        text: entry.modelData.label
                        color: root.onCardMuted
                        font.pixelSize: Appearance.card.detailSize
                        font.weight: Appearance.font.weightIcon
                    }

                    StyledText {
                        Layout.fillWidth: true

                        text: entry.modelData.value
                        color: root.onCard
                        font.pixelSize: Appearance.card.detailSize
                        font.family: Appearance.font.family.mono
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
