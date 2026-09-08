pragma Singleton

import Quickshell
import qs.core.helpers
import qs.modules.border

Singleton {
    id: root

    property bool opened: false
    property string screen: ""

    function show(): void {
        BorderState.closeAll();
        root.screen = Monitors.focused;
        root.opened = true;
    }

    function hide(): void {
        root.opened = false;
    }

    function toggle(): void {
        if (root.opened)
            root.hide();
        else
            root.show();
    }
}
