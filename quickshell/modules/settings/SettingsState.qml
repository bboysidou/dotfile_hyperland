pragma Singleton

import Quickshell
import qs.core.config
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string tab: Appearance.settings.tabServices

    function show(): void {
        Daemons.refresh();
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
