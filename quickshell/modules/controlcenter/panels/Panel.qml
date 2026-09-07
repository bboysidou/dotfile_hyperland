import QtQuick
import QtQuick.Window
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers

RevealCard {
    id: root

    default property alias content: body.data

    function focusStep(forward: bool): void {
        const current = root.Window.activeFocusItem ?? root;
        const next = current.nextItemInFocusChain(forward);
        if (next)
            next.forceActiveFocus();
    }

    implicitWidth: Appearance.control.width

    color: Colours.bar
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: Appearance.control.scaleFrom
    transformOrigin: Item.TopRight

    visible: root.revealed || root.opacity > 0
    focus: root.revealed
    z: root.revealed ? 1 : 0

    onRevealedChanged: {
        if (root.revealed)
            root.forceActiveFocus();
    }

    Keys.onPressed: event => {
        const focus = Nav.vertical(event);

        if (focus !== 0) {
            root.focusStep(focus > 0);
            event.accepted = true;
        }
    }

    Fillet {
        anchors.right: parent.left
        anchors.top: parent.top

        origin: Corner.bottomLeft
    }

    Fillet {
        anchors.right: parent.left
        anchors.bottom: parent.bottom

        origin: Corner.topLeft
    }

    Item {
        id: body

        anchors.fill: parent
        anchors.margins: Appearance.control.padding
    }
}
