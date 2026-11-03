import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.modules.screenshot

PanelWindow {
    id: root

    required property var modelData

    readonly property bool active: PreviewState.shown && PreviewState.screen === root.modelData.name
    readonly property real aspect: image.implicitWidth > 0 ? image.implicitHeight / image.implicitWidth : 0
    readonly property real thumbHeight: Math.max(1, Math.min(Appearance.preview.maxHeight, Appearance.preview.width * root.aspect))
    readonly property var tasks: [
        {
            task: ShotTask.edit,
            icon: Icons.shotEdit
        },
        {
            task: ShotTask.pin,
            icon: Icons.pin
        },
        {
            task: ShotTask.folder,
            icon: Icons.shotFolder
        },
        {
            task: ShotTask.trash,
            icon: Icons.shotTrash
        },
        {
            task: ShotTask.close,
            icon: Icons.editClose
        }
    ]

    function run(task: string): void {
        if (task === ShotTask.edit)
            PreviewState.edit();
        else if (task === ShotTask.pin)
            PreviewState.pin();
        else if (task === ShotTask.folder)
            PreviewState.reveal();
        else if (task === ShotTask.trash)
            PreviewState.trash();
        else
            PreviewState.hide();
    }

    screen: root.modelData
    visible: root.active && image.status === Image.Ready
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: Ids.previewNamespace
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.bottom: true
    anchors.right: true
    margins.bottom: Appearance.preview.margin
    margins.right: Appearance.preview.margin

    implicitWidth: Appearance.preview.width
    implicitHeight: root.thumbHeight + bar.implicitHeight

    ClippingRectangle {
        anchors.fill: parent

        radius: Appearance.preview.rounding
        color: Colours.surface

        Image {
            id: image

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            height: root.thumbHeight

            source: root.active ? `file://${PreviewState.path}` : ""
            sourceSize.width: Appearance.preview.width * Appearance.preview.thumbScale
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: true
        }

        MouseArea {
            anchors.fill: image

            cursorShape: Qt.PointingHandCursor

            onClicked: PreviewState.edit()
        }

        PreviewBar {
            id: bar

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            tasks: root.tasks

            onChosen: task => root.run(task)
        }

        HoverHandler {
            id: hover

            onHoveredChanged: PreviewState.hovered = hover.hovered
        }
    }

    Rectangle {
        anchors.fill: parent

        color: "transparent"
        radius: Appearance.preview.rounding
        border.width: Appearance.preview.border
        border.color: Colours.border
    }
}
