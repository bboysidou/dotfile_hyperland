import QtQuick
import QtCore
import Quickshell
QtObject {
    id: root
    property string category: "PlayerState"
    readonly property Settings storage: Settings {
        location: "file://" + String(Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/quickshell-cassette.ini"
        category: root.category
    }
    function read() {
        try { const data = JSON.parse(String(storage.value("session", "{}"))); return data && typeof data === 'object' && !Array.isArray(data) ? data : {}; }
        catch (_) { return {}; }
    }
    function write(data) { storage.setValue("session", JSON.stringify(data)); storage.sync(); }
}
