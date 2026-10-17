import QtQuick
import qs.core.config
import qs.core.enums

MouseArea {
    id: root

    property bool checked: false

    readonly property int padding: Appearance.control.togglePadding
    readonly property int thumbOn: root.height - root.padding * 2
    readonly property int thumbSize: (root.checked ? root.thumbOn : Appearance.control.toggleThumbOff) + (root.pressed ? Appearance.control.togglePressedGrow : 0)

    signal toggled(bool checked)

    implicitWidth: Appearance.control.toggleWidth
    implicitHeight: Appearance.control.toggleHeight

    cursorShape: Qt.PointingHandCursor
    activeFocusOnTab: true
    opacity: root.enabled ? 1 : Appearance.control.disabledOpacity

    onClicked: root.toggled(!root.checked)

    Keys.onReturnPressed: root.toggled(!root.checked)
    Keys.onSpacePressed: root.toggled(!root.checked)

    StyledRect {
        anchors.fill: parent

        radius: Appearance.rounding.full
        color: root.checked ? Colours.highlight : Colours.trough
        border.width: root.activeFocus || !root.checked ? Appearance.control.toggleBorderWidth : 0
        border.color: root.activeFocus ? Colours.accent : Colours.textMuted

        Behavior on color {
            CAnim {
                type: AnimType.fastEffects
            }
        }

        StyledRect {
            anchors.verticalCenter: parent.verticalCenter

            x: (root.checked ? parent.width - parent.height / 2 : parent.height / 2) - width / 2
            width: root.thumbSize
            height: root.thumbSize
            radius: Appearance.rounding.full
            color: root.checked ? Colours.surface : Colours.textMuted

            Behavior on x {
                Anim {
                    type: AnimType.fastSpatial
                }
            }

            Behavior on width {
                Anim {
                    type: AnimType.fastSpatial
                }
            }

            Behavior on height {
                Anim {
                    type: AnimType.fastSpatial
                }
            }

            Icon {
                anchors.centerIn: parent

                text: Icons.check
                color: Colours.highlight
                font.pixelSize: Appearance.control.toggleIconSize
                opacity: root.checked ? 1 : 0

                Behavior on opacity {
                    Anim {
                        type: AnimType.fastEffects
                    }
                }
            }
        }
    }
}
