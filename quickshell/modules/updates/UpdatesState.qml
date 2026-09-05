pragma Singleton

import Quickshell
import qs.services

Singleton {
    id: root

    property bool opened: false

    function show(): void {
        Updates.refresh();
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
