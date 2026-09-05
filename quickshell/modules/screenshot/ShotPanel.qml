import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.screenshot.components

RevealCard {
    id: root

    signal dismissed

    implicitWidth: Appearance.shot.width
    implicitHeight: layout.implicitHeight + Appearance.shot.padding * 2

    color: Colours.bar
    topLeftRadius: Appearance.border.rounding
    topRightRadius: Appearance.border.rounding
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: Appearance.shot.scaleFrom
    transformOrigin: Item.Bottom

    visible: root.revealed || root.opacity > 0

    onRevealedChanged: {
        if (root.revealed) {
            field.setText(ShotState.search);
            field.focusInput();
        }
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
        anchors.margins: Appearance.shot.padding

        spacing: Appearance.shot.spacing

        TextField {
            id: field

            Layout.fillWidth: true

            placeholder: Appearance.shot.placeholder
            icon: Icons.shotFullscreen

            onEdited: text => ShotState.edit(text)
            onNavigate: delta => list.step(delta)
            onAccepted: ShotState.activate(list.current)
            onCancelled: root.dismissed()
        }

        ShotList {
            id: list

            Layout.fillWidth: true

            search: ShotState.search

            onActivated: entry => ShotState.activate(entry)
        }
    }
}
