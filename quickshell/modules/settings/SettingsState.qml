pragma Singleton

import Quickshell
import qs.core.config
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string tab: Appearance.settings.tabGeneral

    function show(): void {
        root.tab = Appearance.settings.tabGeneral;
        Daemons.refresh();
        InputPrefs.refresh();
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
