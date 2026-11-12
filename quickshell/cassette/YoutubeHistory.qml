import QtQuick
import QtCore
import Quickshell
import "YoutubeUrls.js" as Urls

QtObject {
    id: root
    property var entries: []
    property int limit: 10
    property string category: "YouTubeHistory"
    readonly property string storagePath: String(Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/quickshell-cassette.ini"
    readonly property Settings storage: Settings {
        location: "file://" + root.storagePath
        category: root.category
    }
    function valid(url) { return typeof url === "string" && url.length > 0 && Urls.normalize(url) === url; }
    function restore() {
        let values;
        try { values = JSON.parse(String(storage.value("entries", "[]"))); } catch (_) { values = []; }
        if (!Array.isArray(values)) values = [];
        values = values.filter(item => item && typeof item.url === 'string').map(item => ({url: Urls.normalize(item.url), title: item.title}));
        const seen = new Set();
        entries = values.filter(item => {
            if (!item || !valid(item.url) || seen.has(item.url)) return false;
            seen.add(item.url); return true;
        }).slice(0, limit || undefined).map(item => ({url: item.url, title: typeof item.title === "string" ? item.title : item.url}));
    }
    function contains(url) { return entries.some(item => item.url === url); }
    function remove(url) { entries = entries.filter(item => item.url !== url); save(); }
    function save() { storage.setValue("entries", JSON.stringify(entries)); storage.sync(); }
    function remember(url) {
        if (!valid(url)) return;
        const previous = entries.find(item => item.url === url);
        entries = [{url: url, title: previous ? previous.title : url}].concat(entries.filter(item => item.url !== url)).slice(0, limit || undefined);
        save();
    }
    function updateTitle(url, title) {
        if (!valid(url) || !title || title === url) return;
        if (!entries.some(item => item.url === url)) return;
        entries = entries.map(item => item.url === url ? {url: url, title: String(title)} : item);
        save();
    }
    Component.onCompleted: restore()
}
