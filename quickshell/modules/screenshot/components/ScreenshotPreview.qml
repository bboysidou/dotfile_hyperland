import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.screenshot
import qs.services

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

    function frameEdge(side: string): real {
        return Monitors.covered(root.modelData) ? 0 : Prefs.frameThickness(root.modelData.name, side);
    }

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
    margins.bottom: root.frameEdge(BarEdge.bottom)
    margins.right: root.frameEdge(BarEdge.right)

    implicitWidth: Appearance.preview.width + Appearance.border.fillet
    implicitHeight: root.thumbHeight + bar.implicitHeight + Appearance.border.fillet

    mask: Region {
        item: card
    }

    Item {
        id: card

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: Appearance.preview.width
        height: root.thumbHeight + bar.implicitHeight

        Fillet {
            anchors.right: parent.right
            anchors.bottom: parent.top

            origin: Corner.topLeft
        }

        Fillet {
            anchors.right: parent.left
            anchors.bottom: parent.bottom

            origin: Corner.topLeft
        }

        ClippingRectangle {
            anchors.fill: parent

            color: Colours.bar
            topLeftRadius: Appearance.border.rounding
            topRightRadius: 0
            bottomLeftRadius: 0
            bottomRightRadius: 0

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
    }
}
