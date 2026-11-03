import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.modules.screenshot

PanelWindow {
    id: root

    required property var modelData

    property string screenName: root.modelData.screen

    readonly property var target: Quickshell.screens.find(s => s.name === root.screenName) ?? Quickshell.screens[0]
    readonly property real ratio: (Hyprland.monitorFor(root.target)?.scale ?? 0) > 0 ? Hyprland.monitorFor(root.target).scale : 1
    readonly property real naturalWidth: image.implicitWidth / root.ratio
    readonly property real naturalHeight: image.implicitHeight / root.ratio
    readonly property real fit: root.naturalWidth > 0 ? Math.min(1, root.target.width * Appearance.preview.pinScreenRatio / root.naturalWidth, root.target.height * Appearance.preview.pinScreenRatio / root.naturalHeight) : 1
    readonly property var tasks: [
        {
            task: ShotTask.copy,
            icon: Icons.editCopy
        },
        {
            task: ShotTask.edit,
            icon: Icons.shotEdit
        },
        {
            task: ShotTask.close,
            icon: Icons.editClose
        }
    ]

    property real zoom: 1
    property real left: 0
    property real top: 0

    function place(): void {
        const shift = root.modelData.slot * Appearance.preview.pinCascade;
        root.left = (root.target.width - root.width) / 2 + shift;
        root.top = (root.target.height - root.height) / 2 + shift;
    }

    function move(dx: real, dy: real): void {
        root.left = Math.max(0, Math.min(root.left + dx, root.target.width - root.width));
        root.top = Math.max(0, Math.min(root.top + dy, root.target.height - root.height));
    }

    function hop(dx: real, dy: real): void {
        const halfWidth = root.width / 2;
        const halfHeight = root.height / 2;
        const x = root.target.x + root.left + dx + halfWidth;
        const y = root.target.y + root.top + dy + halfHeight;
        const next = Quickshell.screens.find(s => x >= s.x && x < s.x + s.width && y >= s.y && y < s.y + s.height);
        if (!next || next.name === root.screenName)
            return;
        root.left = x - next.x - halfWidth;
        root.top = y - next.y - halfHeight;
        root.screenName = next.name;
    }

    function scale(steps: real): void {
        root.zoom = Math.max(Appearance.preview.pinMinZoom, Math.min(root.zoom + steps * Appearance.preview.pinZoomStep, Appearance.preview.pinMaxZoom));
    }

    function run(task: string): void {
        if (task === ShotTask.copy)
            Quickshell.execDetached(["bash", "-c", Commands.screenshotCopy, "bash", root.modelData.path]);
        else if (task === ShotTask.edit)
            EditorState.open(root.modelData.path);
        else
            PinState.remove(root.modelData.id);
    }

    screen: root.target
    onWidthChanged: root.move(0, 0)
    onHeightChanged: root.move(0, 0)
    visible: image.status === Image.Ready
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: Ids.pinNamespace
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.top: true
    anchors.left: true
    margins.left: Math.round(root.left)
    margins.top: Math.round(root.top)

    implicitWidth: Math.max(1, Math.round(root.naturalWidth * root.fit * root.zoom))
    implicitHeight: Math.max(1, Math.round(root.naturalHeight * root.fit * root.zoom))

    ClippingRectangle {
        anchors.fill: parent

        radius: Appearance.preview.pinRounding
        color: Colours.surface

        Image {
            id: image

            anchors.fill: parent

            source: `file://${root.modelData.path}`
            cache: false
            smooth: true
            mipmap: true

            onStatusChanged: {
                if (status === Image.Ready)
                    Qt.callLater(root.place);
            }
        }

        MouseArea {
            property real pressX: 0
            property real pressY: 0

            anchors.fill: parent

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

            onPressed: mouse => {
                pressX = mouse.x;
                pressY = mouse.y;
            }
            onPositionChanged: mouse => {
                if (pressedButtons & Qt.LeftButton)
                    root.move(mouse.x - pressX, mouse.y - pressY);
            }
            onReleased: mouse => {
                if (mouse.button === Qt.LeftButton)
                    root.hop(mouse.x - pressX, mouse.y - pressY);
            }
            onClicked: mouse => {
                if (mouse.button !== Qt.LeftButton)
                    PinState.remove(root.modelData.id);
            }
            onDoubleClicked: root.zoom = 1
            onWheel: wheel => root.scale(Math.sign(wheel.angleDelta.y))
        }

        ShotTasks {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Appearance.preview.padding

            visible: hover.hovered
            tasks: root.tasks

            onChosen: task => root.run(task)
        }

        HoverHandler {
            id: hover
        }
    }

    Rectangle {
        anchors.fill: parent

        color: "transparent"
        radius: Appearance.preview.pinRounding
        border.width: Appearance.preview.pinBorder
        border.color: Colours.accent
    }
}
