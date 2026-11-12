//@ pragma UseQApplication
// Use Qt Compose until native Wayland text-input focus transitions are reliable.
//@ pragma DefaultEnv QT_IM_MODULE=compose
//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded
//@ pragma IconTheme kora-robot

import Quickshell
import qs.cassette
import qs.modules.background
import qs.modules.border
import qs.modules.controlcenter
import qs.modules.dashboard
import qs.modules.display
import qs.modules.fingerprint
import qs.modules.hardware
import qs.modules.keybinds
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.polkit
import qs.modules.power
import qs.modules.prayers
import qs.modules.screenshot
import qs.modules.settings
import qs.modules.share
import qs.modules.theme
import qs.modules.updates
import qs.modules.wallpaper

ShellRoot {
    id: root

    settings.watchFiles: true

    DeckWindow { visible: false }

    Background {}
    Border {}
    ControlCenter {}
    Dashboard {}
    DisplayCenter {}
    FingerprintCenter {}
    HardwareCenter {}
    KeybindSheet {}
    Launcher {}
    Lock {}
    Notifications {}
    Osd {}
    Polkit {}
    Power {}
    PrayerModule {}
    Screenshot {}
    SettingsCenter {}
    Share {}
    ThemePicker {}
    UpdatesCenter {}
    Picker {}
}
