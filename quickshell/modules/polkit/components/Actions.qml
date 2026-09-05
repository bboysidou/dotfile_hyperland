pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    component Action: StyledRect {
        id: action

        required property string label
        required property color accent

        signal activated

        implicitWidth: text.implicitWidth + Appearance.polkit.actionPaddingH * 2
        implicitHeight: text.implicitHeight + Appearance.polkit.actionPaddingV * 2

        color: area.containsMouse ? Colours.hover : Colours.pill
        radius: Appearance.polkit.actionRounding

        StyledText {
            id: text

            anchors.centerIn: parent

            text: action.label
            color: action.accent
            font.pixelSize: Appearance.polkit.bodySize
        }

        MouseArea {
            id: area

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: action.activated()
        }
    }

    signal confirmed
    signal cancelled

    spacing: Appearance.polkit.actionSpacing
    layoutDirection: Qt.RightToLeft

    Action {
        label: Appearance.polkit.confirmLabel
        accent: Colours.accent

        onActivated: root.confirmed()
    }

    Action {
        label: Appearance.polkit.cancelLabel
        accent: Colours.textMuted

        onActivated: root.cancelled()
    }
}
