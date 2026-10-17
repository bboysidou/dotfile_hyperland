import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.share.components

RevealCard {
    id: root

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

        TabStrip {
            tabs: ShareState.tabs
            current: ShareState.section

            onSelected: section => ShareState.show(section)
        }

        ShareGrid {
            Layout.fillWidth: true

            live: root.revealed
        }

        ShareActions {
            Layout.fillWidth: true
        }
    }

    ShareKeys {
        id: keys
    }
}
