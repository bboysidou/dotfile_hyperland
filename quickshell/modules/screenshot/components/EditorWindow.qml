import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.modules.screenshot

PanelWindow {
    id: root

    required property var modelData

    readonly property bool active: EditorState.opened && EditorState.screen === root.modelData.name
    readonly property real available: root.height - Appearance.editor.margin * 2 - Appearance.editor.toolbarHeight - Appearance.editor.gap
    readonly property bool cropping: EditorState.tool === EditTool.crop
    readonly property var shown: root.cropping ? EditorState.full : EditorState.view
    readonly property int pad: root.cropping ? 0 : EditorState.pad
    readonly property real fit: root.shown.width > 0 ? Math.min((root.width - Appearance.editor.margin * 2) / (root.shown.width + root.pad * 2), root.available / (root.shown.height + root.pad * 2), 1) : 1

    screen: root.modelData
    visible: root.active
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: Ids.editorNamespace
    WlrLayershell.keyboardFocus: root.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    onActiveChanged: {
        if (root.active)
            keys.forceActiveFocus();
    }

    Connections {
        target: EditorState

        function onEditingChanged(): void {
            if (EditorState.editing < 0 && root.active)
                keys.forceActiveFocus();
        }

        function onExportRequested(output: string): void {
            if (root.active)
                exporter.render(output);
        }
    }

    Rectangle {
        anchors.fill: parent

        color: Colours.shadow
        opacity: Appearance.editor.dimOpacity
    }

    EditorSheet {
        id: sheet

        x: (root.width - sheet.width) / 2
        y: Appearance.editor.margin + (root.available - sheet.height) / 2
        zoom: root.fit
        view: root.shown
        pad: root.pad
        live: root.active
    }

    EditorCropShade {
        anchors.fill: sheet

        visible: root.cropping
        zoom: root.fit
    }

    EditorInput {
        anchors.fill: sheet

        zoom: root.fit
        originX: root.shown.x - root.pad
        originY: root.shown.y - root.pad
    }

    EditorToolbar {
        anchors.horizontalCenter: parent.horizontalCenter
        y: sheet.y + sheet.height + Appearance.editor.gap
    }

    EditorKeys {
        id: keys
    }

    EditorExport {
        id: exporter

        x: -width - Appearance.editor.margin
        screen: root.modelData
    }
}
