import QtQuick

Item {
    id: root

    default property Component component
    property bool open: false
    property Item item: null

    readonly property bool shown: root.item !== null && root.item.opacity > 0

    function sync(): void {
        if ((root.open || root.shown) && root.item === null) {
            const panel = root.component.createObject(root);
            panel.revealed = Qt.binding(() => root.open);
            root.item = panel;
        } else if (!root.open && !root.shown && root.item !== null) {
            const panel = root.item;
            root.item = null;
            panel.destroy();
        }
    }

    anchors.fill: parent
    z: root.open ? 1 : 0

    onOpenChanged: root.sync()
    onShownChanged: Qt.callLater(root.sync)

    MouseArea {
        x: root.item?.x ?? 0
        y: root.item?.y ?? 0
        width: root.item?.width ?? 0
        height: root.item?.height ?? 0

        enabled: root.item !== null
        acceptedButtons: Qt.AllButtons
    }
}
