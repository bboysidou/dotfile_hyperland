//@ pragma UseQApplication
//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded
//@ pragma IconTheme FairyWren_black_Dark

import Quickshell
import qs.modules.background
import qs.modules.border
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.polkit
import qs.modules.power
import qs.modules.screenshot
import qs.modules.wallpaper

ShellRoot {
    id: root

    settings.watchFiles: true

    Background {}
    Border {}
    ControlCenter {}
    Dashboard {}
    Launcher {}
    Lock {}
    Notifications {}
    Osd {}
    Polkit {}
    Power {}
    Screenshot {}
    Picker {}
}
