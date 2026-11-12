import QtQuick
import "YoutubeUrls.js" as Urls

Item {
    id: root
    readonly property YoutubeEngine youtubeBackend: youtube
    readonly property var youtubeHistory: history.entries
    readonly property var favorites: favoritesStore.entries
    property bool online: false
    property real volume: 0.5
    property string validationError: ""
    property string sourceUrl: ""
    property string sourceTitle: ""
    property var queue: []
    property int queueIndex: -1
    property bool ready: false
    readonly property bool mix: online && Urls.isMix(sourceUrl)
    readonly property bool playlist: online && Urls.isPlaylist(sourceUrl)
    readonly property string currentUrl: online && queueIndex >= 0 && queueIndex < queue.length ? queue[queueIndex].url : ""
    readonly property var tracks: online ? queue.map(e => e.url) : local.tracks
    readonly property int index: online ? queueIndex : local.index
    readonly property bool playing: online ? youtube.playing : local.playing
    readonly property bool loading: online ? (resolver.busy || youtube.loading) : local.scanning
    readonly property string title: online ? (resolver.busy ? "Chargement de la playlist…" : youtube.title) : local.title
    readonly property string artist: online ? youtube.artist : local.artist
    readonly property string error: validationError || (online ? youtube.error : local.error)
    readonly property real position: online ? youtube.position : local.player.position
    readonly property real duration: online ? youtube.duration : local.player.duration
    readonly property bool seekable: online ? youtube.seekable : local.player.seekable
    function time(ms) { return local.time(ms); }
    function open(url) {
        if (Urls.normalize(url)) return openYoutube(url);
        load([url]); return true;
    }
    function load(urls) { resolver.cancel(); youtube.stop(); validationError = ""; online = false; local.load(urls); scheduleSave(); }
    function openFolder(url) { resolver.cancel(); youtube.stop(); validationError = ""; online = false; local.stop(); local.openFolder(url); }
    function openYoutube(input) {
        const url = Urls.normalize(input);
        if (!url) { validationError = "Collez le lien d’une vidéo ou d’une playlist YouTube."; return false; }
        resolver.cancel(); youtube.stop(); local.stop(); local.scanning = false;
        validationError = ""; online = true; sourceUrl = url; sourceTitle = url; queue = []; queueIndex = -1;
        history.remember(url);
        if (Urls.isPlaylist(url)) resolver.open(url);
        else { queue = [{url: url, title: url}]; choose(0, true); }
        scheduleSave(); return true;
    }
    function play() {
        validationError = "";
        if (!online) local.play();
        else if (!resolver.busy && queueIndex >= 0) youtube.play();
        else if (!resolver.busy && sourceUrl) openYoutube(sourceUrl);
    }
    function pause() { online ? youtube.pause() : local.player.pause(); save(); }
    function stop() { if (online) { resolver.cancel(); youtube.stop(); } else local.stop(); save(); }
    function seek(ms) { if (online) youtube.seek(ms); else if (seekable) local.player.position = ms; scheduleSave(); }
    function next() {
        if (!online) local.next();
        else if (queueIndex + 1 < queue.length) choose(queueIndex + 1, true);
        else if (queue.length <= 1 && !playlist) validationError = "Ce lien contient une seule vidéo. Ouvrez le lien complet avec list=… pour enchaîner une playlist.";
    }
    function previous() {
        if (!online) local.previous();
        else if (position > 3000 && seekable) youtube.seek(0);
        else if (queueIndex > 0) choose(queueIndex - 1, true);
        else youtube.seek(0);
    }
    function choose(i, autoplay) {
        if (!online) local.choose(i, autoplay);
        else if (i >= 0 && i < queue.length) {
            queueIndex = i;
            youtube.open(queue[i].url, autoplay);
        }
        scheduleSave();
    }
    function trackLabel(url) { const e = queue.find(e => e.url === url); return online ? (e ? e.title : url) : decodeURIComponent(String(url).split('/').pop()); }
    function isFavorite(url) { return favoritesStore.contains(url); }
    function toggleFavorite(url, title) {
        const normalized = Urls.normalize(url); if (!normalized) return;
        if (favoritesStore.contains(normalized)) favoritesStore.remove(normalized);
        else { favoritesStore.remember(normalized); favoritesStore.updateTitle(normalized, title || normalized); }
    }
    function removeFavorite(url) { favoritesStore.remove(url); }
    function applyPlaylist(url, title, entries) {
        if (!online || sourceUrl !== url) return;
        sourceTitle = title; queue = entries; queueIndex = -1;
        history.updateTitle(url, title); favoritesStore.updateTitle(url, title);
        const seed = Urls.videoId(url);
        const first = seed ? entries.findIndex(e => Urls.videoId(e.url) === seed) : 0;
        choose(first >= 0 ? first : 0, true);
    }
    function scheduleSave() { if (ready) checkpoint.restart(); }
    function save() {
        if (!ready) return;
        session.write({version: 1, volume: volume, online: online, sourceUrl: sourceUrl, sourceTitle: sourceTitle,
            queue: queue, queueIndex: queueIndex, tracks: local.tracks, localIndex: local.index, position: position});
    }
    function restore() {
        const state = session.read();
        volume = Number.isFinite(state.volume) ? Math.max(0, Math.min(1, state.volume)) : 0.5;
        const ms = Number.isFinite(state.position) ? Math.max(0, state.position) : 0;
        if (state.online && Urls.normalize(state.sourceUrl)) {
            online = true; sourceUrl = Urls.normalize(state.sourceUrl); sourceTitle = String(state.sourceTitle || sourceUrl);
            queue = Array.isArray(state.queue) ? state.queue.filter(e => e && typeof e.url === 'string' && Urls.normalize(e.url) === e.url && !Urls.isPlaylist(e.url)).map(e => ({url: e.url, title: String(e.title || e.url)})) : [];
            queueIndex = queue.length ? Math.max(0, Math.min(Number.isInteger(state.queueIndex) ? state.queueIndex : 0, queue.length - 1)) : -1;
            if (queueIndex >= 0) youtube.restore(currentUrl, queue[queueIndex].title, ms);
        } else if (Array.isArray(state.tracks)) {
            local.restore(state.tracks.filter(u => typeof u === 'string' && u.startsWith('file:///')), Number.isInteger(state.localIndex) ? state.localIndex : 0, ms);
        }
        ready = true;
    }
    onVolumeChanged: scheduleSave()
    onIndexChanged: scheduleSave()
    onTracksChanged: scheduleSave()
    onPlayingChanged: scheduleSave()
    Component.onCompleted: restore()
    // Save before child backends are destroyed; periodic checkpoints cover crashes.
    Component.onDestruction: save()
    Timer { id: checkpoint; interval: 350; onTriggered: root.save() }
    Timer { interval: 5000; repeat: true; running: root.ready && root.playing; onTriggered: root.save() }
    DeckState { id: session }
    DeckEngine { id: local; volume: root.volume }
    YoutubeHistory { id: history }
    YoutubeHistory { id: favoritesStore; category: "YouTubeFavorites"; limit: 0 }
    YoutubePlaylist {
        id: resolver
        onResolved: (url, title, entries) => root.applyPlaylist(url, title, entries)
        onFailed: (url, message) => { if (root.online && root.sourceUrl === url) root.validationError = message; }
    }
    YoutubeEngine {
        id: youtube; volume: root.volume
        onTitleResolved: (url, title) => {
            if (!root.online || root.currentUrl !== url) return;
            root.queue = root.queue.map(e => e.url === url ? {url: url, title: title} : e);
            if (!root.playlist) { root.sourceTitle = title; history.updateTitle(url, title); }
            favoritesStore.updateTitle(url, title); root.scheduleSave();
        }
        onFinished: { if (root.online) root.next(); }
        onPlaybackFailed: message => {
            if (root.online && root.queueIndex + 1 < root.queue.length) {
                root.validationError = "Piste indisponible, passage à la suivante. " + message;
                root.next();
            }
        }
    }
}
