pragma Singleton

import Quickshell
import qs.core.config
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string tab: Appearance.updates.tabRepo

    function show(): void {
        root.tab = Updates.repo.length === 0 && Updates.aur.length > 0 ? Appearance.updates.tabAur : Appearance.updates.tabRepo;
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
