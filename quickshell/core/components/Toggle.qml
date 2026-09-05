import QtQuick
import qs.core.config
import qs.core.enums

MouseArea {
    id: root

    property bool checked: false

    signal toggled(bool checked)

    implicitWidth: Appearance.control.toggleWidth
    implicitHeight: Appearance.control.toggleHeight

    cursorShape: Qt.PointingHandCursor
    activeFocusOnTab: true

    onClicked: root.toggled(!root.checked)

    Keys.onReturnPressed: root.toggled(!root.checked)
    Keys.onSpacePressed: root.toggled(!root.checked)

    StyledRect {
        anchors.fill: parent

        radius: Appearance.rounding.full
        color: root.checked ? Colours.highlight : Colours.trough
        opacity: root.enabled ? 1 : Appearance.control.disabledOpacity
        border.width: root.activeFocus ? Appearance.control.focusBorderWidth : 0
        border.color: Colours.accent

        Behavior on color {
            CAnim {
                type: AnimType.fastEffects
            }
        }

        StyledRect {
            y: Appearance.control.togglePadding
            x: root.checked ? parent.width - width - Appearance.control.togglePadding : Appearance.control.togglePadding

            width: parent.height - Appearance.control.togglePadding * 2
            height: width
            radius: Appearance.rounding.full
            color: Colours.surface

            Behavior on x {
                Anim {
                    type: AnimType.fastSpatial
                }
            }
        }
    }
}
