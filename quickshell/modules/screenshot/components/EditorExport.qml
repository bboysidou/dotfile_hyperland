import QtQuick
import Quickshell.Hyprland
import qs.core.config
import qs.core.helpers
import qs.modules.screenshot

Item {
    id: root

    required property var screen

    readonly property real ratio: (Hyprland.monitorFor(root.screen)?.scale ?? 0) > 0 ? Hyprland.monitorFor(root.screen).scale : 1
    readonly property string size: `${EditorState.view.width + EditorState.pad * 2}x${EditorState.view.height + EditorState.pad * 2}`

    function render(output: string): void {
        EditorState.finishText();
        EditorState.selected = -1;
        EditorState.serial += 1;
        const temp = `${Paths.runtime}/${Appearance.screenshot.tempFile.arg("editor").arg(String(Date.now())).arg(String(EditorState.serial))}`;
        const started = root.grabToImage(result => {
            if (result.saveToFile(temp))
                EditorOutput.deliver(temp, output, root.size);
            else
                ScreenshotState.fail(Appearance.screenshot.failSave);
        });
        if (!started)
            ScreenshotState.fail(Appearance.screenshot.failGrab);
    }

    width: sheet.width
    height: sheet.height

    EditorSheet {
        id: sheet

        zoom: 1 / root.ratio
        view: EditorState.view
        pad: EditorState.pad
    }
}
