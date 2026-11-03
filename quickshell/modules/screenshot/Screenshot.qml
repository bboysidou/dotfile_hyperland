import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.modules.screenshot.components

Scope {
    GlobalShortcut {
        appid: Ids.appid
        name: "screenshot"

        onPressed: ShotState.toggle()
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "screenshot-capture"

        onPressed: ScreenshotState.toggle()
    }

    IpcHandler {
        target: "screenshot"

        function open(): string {
            ShotState.show();
            return IpcStatus.open;
        }

        function close(): string {
            ShotState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            ShotState.toggle();
            return ShotState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function ocr(): string {
            ShotState.run(ShotAction.ocr);
            return IpcStatus.started;
        }

        function capture(): string {
            ScreenshotState.toggle();
            return ScreenshotState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function monitor(): string {
            ScreenshotState.open(ScreenshotMode.monitor);
            return ScreenshotState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function edit(path: string): string {
            EditorState.open(path);
            return EditorState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function editClose(): string {
            EditorState.close();
            return IpcStatus.closed;
        }

        function pin(path: string): string {
            PinState.add(path);
            return IpcStatus.open;
        }

        function unpin(): string {
            PinState.clear();
            return IpcStatus.closed;
        }

        function preview(path: string): string {
            PreviewState.show(path);
            return IpcStatus.open;
        }

        function fullscreen(): string {
            ScreenshotState.open(ScreenshotMode.all);
            return IpcStatus.started;
        }
    }

    Variants {
        model: Quickshell.screens

        ScreenshotOverlay {}
    }

    Variants {
        model: Quickshell.screens

        EditorWindow {}
    }

    Variants {
        model: Quickshell.screens

        ScreenshotPreview {}
    }

    Variants {
        model: PinState.pins

        ScreenshotPin {}
    }
}
