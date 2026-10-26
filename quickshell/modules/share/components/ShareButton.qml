import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property string label
    property string icon: ""
    property bool accent: false
    property color tint: Colours.accent
    property bool disabled: false

    signal activated

    implicitWidth: content.implicitWidth + Appearance.share.actionPaddingH * 2
    implicitHeight: content.implicitHeight + Appearance.share.actionPaddingV * 2

    color: root.accent ? root.tint : Colours.pill
    radius: Appearance.share.actionRounding
    opacity: root.disabled ? Appearance.share.disabledOpacity : 1

    StateLayer {
        disabled: root.disabled

        onClicked: root.activated()
    }

    RowLayout {
        id: content

        anchors.centerIn: parent

        spacing: Appearance.share.actionContentSpacing

        Icon {
            visible: root.icon !== ""
            text: root.icon
            color: root.accent ? Colours.surface : Colours.text
            font.pixelSize: Appearance.share.actionIconSize
        }

        StyledText {
            text: root.label
            color: root.accent ? Colours.surface : Colours.text
            font.pixelSize: Appearance.share.bodySize
        }
    }
}
