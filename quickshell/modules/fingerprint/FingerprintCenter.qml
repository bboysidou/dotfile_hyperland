import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.core.constants
import qs.core.enums
import qs.services

Scope {
    GlobalShortcut {
        appid: Ids.appid
        name: "fingerprint"

        onPressed: FingerprintState.toggle()
    }

    IpcHandler {
        target: "fingerprint"

        function open(): string {
            FingerprintState.show();
            return IpcStatus.open;
        }

        function close(): string {
            FingerprintState.hide();
            return IpcStatus.closed;
        }

        function status(): string {
            return JSON.stringify({
                opened: FingerprintState.opened,
                enrollOpened: FingerprintState.enrollOpened,
                installed: Fingerprint.installed,
                present: Fingerprint.present,
                device: Fingerprint.deviceName,
                fingers: Fingerprint.fingers,
                sudo: Fingerprint.sudoEnabled,
                phase: FingerprintEnroll.phase,
                stage: FingerprintEnroll.stage,
                stages: FingerprintEnroll.stages
            });
        }
    }
}
