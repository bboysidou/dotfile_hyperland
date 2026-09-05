pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.enums

Singleton {
    id: root

    property bool primed: false
    property bool visible: false
    property string kind: OsdKind.volume

    function show(target: string): void {
        if (!root.primed)
            return;

        root.kind = target;
        root.visible = true;
        hide.restart();
    }

    Timer {
        id: hide

        interval: Appearance.osd.timeout

        onTriggered: root.visible = false
    }

    Timer {
        interval: Appearance.osd.primeDelay
        running: true

        onTriggered: root.primed = true
    }

    Connections {
        target: Audio

        function onPercentChanged(): void {
            root.show(OsdKind.volume);
        }

        function onMutedChanged(): void {
            root.show(OsdKind.volume);
        }
    }

    Connections {
        target: Audio.source?.audio ?? null

        function onMutedChanged(): void {
            root.show(OsdKind.microphone);
        }

        function onVolumeChanged(): void {
            root.show(OsdKind.microphone);
        }
    }

    Connections {
        target: Brightness

        function onPercentChanged(): void {
            root.show(OsdKind.brightness);
        }
    }
}
