import QtQuick
import QtQuick.Layouts
import qs.core.config

StyledRect {
    id: root

    default property alias content: layout.data
    property bool interactive: true

    readonly property alias hovered: pointer.containsMouse
    readonly property alias contentHeight: layout.implicitHeight

    signal activated
    signal exited

    color: root.activeFocus ? Colours.hover : Colours.pill
    radius: Appearance.control.rowRounding
    border.width: root.activeFocus ? Appearance.control.focusBorderWidth : 0
    border.color: Colours.accent

    activeFocusOnTab: true

    implicitHeight: Appearance.control.rowHeight

    data: [
        StateLayer {
            id: pointer

            disabled: !root.interactive

            onClicked: root.activated()
            onExited: root.exited()
        },
        RowLayout {
            id: layout

            anchors.fill: parent
            anchors.leftMargin: Appearance.control.rowPaddingH
            anchors.rightMargin: Appearance.control.rowPaddingH

            spacing: Appearance.control.rowSpacing
        }
    ]
}
