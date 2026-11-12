import Quickshell
import Quickshell.Io
import qs.services

Scope {
    id: root

    readonly property bool active: loader.active
    LazyLoader {
        id: loader
        active: Prefs.loaded && Prefs.prayersEnabled
        component: PrayerCenter {}
    }

    IpcHandler {
        target: "prayerControl"
        function status(): string {
            return `enabled=${Prefs.prayersEnabled} loaded=${root.active} ready=${Prayer.backend ? Prayer.backend.ready : false}`;
        }
        function setEnabled(enabled: bool): string {
            if (!Prefs.loaded)
                return "preferences not loaded";
            Prefs.set("prayersEnabled", enabled);
            return enabled ? "enabled" : "disabled";
        }
    }
}
