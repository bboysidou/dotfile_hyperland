pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums

Singleton {
    id: root

    readonly property int noText: 3

    function deliver(temp: string, output: string, size: string): void {
        if (output === EditOutput.ocr) {
            reader.createObject(root, {
                command: ["bash", "-c", Commands.editorOcr, "bash", temp, Appearance.editor.ocrLanguage]
            });
            return;
        }
        const base = Qt.formatDateTime(new Date(), Appearance.screenshot.filePattern);
        exporter.createObject(root, {
            output: output,
            command: ["bash", "-c", Commands.editorExport, "bash", temp, output, ScreenshotState.dir, base, String(Appearance.screenshot.maxSuffix), size]
        });
        if (output === EditOutput.both || output === EditOutput.pin)
            EditorState.close();
    }

    function delivered(output: string, path: string): void {
        if (output === EditOutput.copy)
            Quickshell.execDetached([...Commands.editorCopied, Appearance.editor.copiedTitle]);
        else if (output === EditOutput.pin)
            PinState.add(path);
        else
            ScreenshotState.announce(path, Appearance.editor.editedLabel);
    }

    function read(code: int, text: string): void {
        if (code === 0)
            Quickshell.execDetached([...Commands.editorCopied, Appearance.editor.ocrTitle, text.slice(0, Appearance.editor.ocrPreviewLength)]);
        else if (code === root.noText)
            Quickshell.execDetached([...Commands.editorCopied, Appearance.editor.ocrEmpty]);
        else
            ScreenshotState.fail(Appearance.editor.failOcr);
    }

    Component {
        id: exporter

        Process {
            id: proc

            property string output: ""

            running: true

            stdout: StdioCollector {
                id: printed
            }

            onExited: code => {
                if (code === 0)
                    root.delivered(proc.output, printed.text);
                else
                    ScreenshotState.fail(Appearance.editor.failExport);
                proc.destroy();
            }
        }
    }

    Component {
        id: reader

        Process {
            id: ocr

            running: true

            stdout: StdioCollector {
                id: recognised
            }

            onExited: code => {
                root.read(code, recognised.text);
                ocr.destroy();
            }
        }
    }
}
