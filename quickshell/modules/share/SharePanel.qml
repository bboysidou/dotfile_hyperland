import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.share.components

RevealCard {
    id: root

    readonly property color accent: tabBar.fill

    outlineColour: tabBar.fill
    implicitWidth: Appearance.share.width
    implicitHeight: layout.implicitHeight + Appearance.share.padding * 2

    color: Colours.bar
    topLeftRadius: Appearance.border.rounding
    topRightRadius: Appearance.border.rounding
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: Appearance.share.scaleFrom
    transformOrigin: Item.Bottom

    visible: root.revealed || root.opacity > 0

    onRevealedChanged: {
        if (root.revealed)
            keys.forceActiveFocus();
    }

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

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.share.padding

        spacing: Appearance.share.spacing

        ShareHeader {
            Layout.fillWidth: true
        }

        SegmentBar {
            id: tabBar

            Layout.fillWidth: true

            options: ShareState.tabs
            current: ShareState.section

            onSelected: key => ShareState.show(key)
        }

        ShareGrid {
            Layout.fillWidth: true

            live: root.revealed
            accent: root.accent
        }

        ShareActions {
            Layout.fillWidth: true

            accent: root.accent
        }
    }

    ShareKeys {
        id: keys
    }
}
