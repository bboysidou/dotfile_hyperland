pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

Rectangle {
    id: root

    required property Notif modelData

    readonly property color tint: modelData.critical ? Colours.urgencyCritical : Colours.textMuted
    readonly property string glyph: modelData.critical ? Icons.notifCritical : Icons.notifNormal
    readonly property bool aged: Time.now.getTime() - modelData.created >= Appearance.notif.ageThreshold * 1000

    property bool entered

    Layout.fillWidth: true

    implicitWidth: Num.clamp(layout.implicitWidth + Appearance.notif.paddingH * 2, Appearance.notif.widthMin, Appearance.notif.widthMax)
    readonly property int contentHeight: Num.clamp(layout.implicitHeight + Appearance.notif.paddingV * 2, Appearance.notif.heightMin, Appearance.notif.heightMax)

    implicitHeight: root.entered && !root.modelData.closing ? root.contentHeight : 0

    Behavior on implicitHeight {
        Anim {
            type: AnimType.standardSmall
        }
    }

    color: root.modelData.critical ? Colours.criticalSurface : Colours.pill
    radius: Appearance.notif.rounding
    antialiasing: true
    clip: true

    opacity: root.entered && !root.modelData.closing ? 1 : 0

    transform: Translate {
        x: root.entered && !root.modelData.closing ? 0 : Appearance.notif.slideDistance

        Behavior on x {
            Anim {
                type: AnimType.fastSpatial
            }
        }
    }

    Behavior on opacity {
        Anim {
            type: AnimType.defaultEffects
        }
    }

    MouseArea {
        anchors.fill: parent

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
        anchors.bottomMargin: Appearance.notif.paddingV

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

                StyledText {
                    Layout.fillWidth: true

                    text: root.modelData.summary
                    color: root.modelData.critical ? Colours.urgencyCritical : Colours.textBright
                    font.weight: Appearance.font.weightActive
                    elide: Text.ElideRight
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

            RowLayout {
                visible: root.modelData.buttons.length > 0

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

    Component.onCompleted: root.entered = true
}
