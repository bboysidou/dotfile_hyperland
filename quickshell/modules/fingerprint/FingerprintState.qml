pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.enums
import qs.services

Singleton {
    id: root

    property bool opened: false
    property bool enrollOpened: false

    function show(): void {
        Fingerprint.refresh();
        root.opened = true;
    }

    function hide(): void {
        doneHold.stop();
        root.opened = false;
        root.enrollOpened = false;

        if (FingerprintEnroll.enrolling)
            FingerprintEnroll.cancel();
        else
            FingerprintEnroll.acknowledge();
    }

    function toggle(): void {
        if (root.opened || root.enrollOpened)
            root.hide();
        else
            root.show();
    }

    function enroll(finger: string): void {
        root.enrollOpened = true;
        root.opened = false;
        FingerprintEnroll.start(finger);
    }

    function closeEnroll(): void {
        doneHold.stop();

        if (FingerprintEnroll.enrolling)
            FingerprintEnroll.cancel();
        else
            FingerprintEnroll.acknowledge();

        root.show();
        root.enrollOpened = false;
    }

    Connections {
        target: FingerprintEnroll

        function onPhaseChanged(): void {
            if (root.enrollOpened && FingerprintEnroll.phase === FingerprintPhase.done)
                doneHold.restart();
        }
    }

    Timer {
        id: doneHold

        interval: Appearance.fingerprint.doneHold

        onTriggered: root.closeEnroll()
    }
}
