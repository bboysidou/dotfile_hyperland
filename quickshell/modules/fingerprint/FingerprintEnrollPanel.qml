import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.fingerprint.components

RevealCard {
    id: root

    readonly property var config: Appearance.fingerprint

    outlineColour: Colours.accent
    implicitWidth: root.config.width
    implicitHeight: view.implicitHeight + root.config.enrollPadding * 2

    color: Colours.bar
    topLeftRadius: Appearance.border.rounding
    topRightRadius: Appearance.border.rounding
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: root.config.scaleFrom
    transformOrigin: Item.Bottom

    visible: root.revealed || root.opacity > 0
    focus: root.revealed

    onRevealedChanged: {
        if (root.revealed)
            root.forceActiveFocus();
    }

    Keys.onEscapePressed: FingerprintState.closeEnroll()

    Behavior on implicitHeight {
        Anim {
            type: AnimType.emphasizedSmall
        }
    }

    Fillet {
        anchors.right: parent.left
        anchors.bottom: parent.bottom

        origin: Corner.topLeft
    }

    Fillet {
        anchors.left: parent.right
        anchors.bottom: parent.bottom

        origin: Corner.topRight
    }

    EnrollView {
        id: view

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.config.enrollPadding
    }
}
