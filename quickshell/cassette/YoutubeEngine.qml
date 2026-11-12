import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    property string url: ""
    property string title: "YouTube"
    property string artist: "YouTube"
    property string error: ""
    property real volume: 0.5
    property real position: 0
    property real duration: 0
    property bool seekable: false
    property bool loading: false
    property bool loaded: false
    property bool paused: true
    property bool buffering: false
    property bool pendingLoad: false
    property bool pendingPause: false
    property int attempts: 0
    property bool awaitingStart: false
    property int activeEntryId: -1
    property int loadSerial: 1000
    property string lastDiagnostic: ""
    readonly property bool playing: loaded && !paused && !buffering
    readonly property string socketPath: String(Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/cassette-" + Quickshell.processId + "-" + token + ".sock"
    readonly property string token: Math.random().toString(36).slice(2, 9)
    readonly property var observed: ["time-pos", "duration", "pause", "paused-for-cache", "seekable", "media-title", "metadata"]
    signal commandSent(var command)
    property real resumePosition: -1
    signal finished()
    signal playbackFailed(string message)
    signal titleResolved(string url, string title)

    // Only individual public YouTube video URLs. Strip playlist/tracking parameters.
    function normalize(input) {
        const value = String(input).trim();
        const match = value.match(/^https?:\/\/(?:www\.|m\.|music\.)?(youtube\.com|youtu\.be)\/([^\s#]*)(?:#[^\s]*)?$/i);
        if (!match) return "";
        let id = "";
        if (match[1].toLowerCase() === "youtu.be") id = match[2].split(/[?\/]/)[0];
        else if (match[2].startsWith("watch?")) {
            const query = match[2].slice(6).split('&');
            const v = query.find(part => part.startsWith('v='));
            if (v) id = v.slice(2);
        } else {
            const path = match[2].match(/^(?:shorts|live|embed)\/([A-Za-z0-9_-]{11})(?:[?\/].*)?$/);
            if (path) id = path[1];
        }
        return /^[A-Za-z0-9_-]{11}$/.test(id) ? "https://www.youtube.com/watch?v=" + id : "";
    }
    function send(command, requestId) {
        commandSent(command);
        if (ipc.connected) { ipc.write(JSON.stringify({command: command, request_id: requestId || 0}) + "\n"); ipc.flush(); }
    }
    function reset() {
        loaded = false; paused = true; buffering = false;
        position = 0; duration = 0; seekable = false;
    }
    function open(input, autoplay, startAt) {
        const normalized = normalize(input);
        if (!normalized) { error = "Collez le lien d’une vidéo YouTube (watch, youtu.be, Shorts ou live)."; return false; }
        url = normalized; awaitingStart = true; loadSerial++; error = ""; lastDiagnostic = "";
        reset(); title = "Chargement YouTube…"; artist = "YouTube";
        loading = true; pendingLoad = true; pendingPause = autoplay === false; resumePosition = Number.isFinite(startAt) ? Math.max(0, startAt) : -1; attempts = 0;
        if (!mpv.running) mpv.running = true;
        if (ipc.connected) loadPending();
        loadDeadline.restart();
        return true;
    }
    function restore(urlValue, titleValue, ms) {
        stop(); url = urlValue; title = titleValue || urlValue; artist = "YouTube";
        resumePosition = Math.max(0, Number(ms) || 0); position = resumePosition;
    }
    function applyResume() {
        if (loaded && seekable && resumePosition >= 0) { const ms = resumePosition; resumePosition = -1; seek(ms); }
    }
    onSeekableChanged: applyResume()
    function loadPending() {
        if (!pendingLoad) return;
        pendingLoad = false;
        send(["set_property", "volume", Math.round(volume * 100)]);
        send(["loadfile", url, "replace"], loadSerial);
        send(["set_property", "pause", pendingPause]);
    }
    function play() {
        if (!url) return;
        if (loaded) { send(["set_property", "pause", false]); return; }
        if (loading) { pendingPause = false; send(["set_property", "pause", false]); return; }
        open(url, true, resumePosition);
    }
    function pause() {
        pendingPause = true;
        if (ipc.connected) send(["set_property", "pause", true]);
    }
    function stop() {
        awaitingStart = true; pendingLoad = false; loading = false; resumePosition = -1; loadDeadline.stop();
        if (ipc.connected) send(["stop"]);
        reset();
    }
    function seek(ms) { if (seekable) send(["seek", Math.max(0, ms) / 1000, "absolute+exact"]); }
    function fail(message) {
        stop(); error = message; title = "YouTube · lecture indisponible";
    }
    function receive(line) {
        let message;
        try { message = JSON.parse(line); } catch (_) { return; }
        if (message.request_id === loadSerial && message.error && message.error !== "success") {
            fail("mpv refuse la piste : " + message.error); playbackFailed(error); return;
        }
        if (message.request_id >= 100 && message.request_id < 100 + observed.length && message.error === "success") {
            receive(JSON.stringify({event: "property-change", name: observed[message.request_id - 100], data: message.data}));
            return;
        }
        if (message.event === "start-file") {
            activeEntryId = Number.isInteger(message.playlist_entry_id) ? message.playlist_entry_id : -1;
            awaitingStart = false;
        } else if (message.event === "file-loaded") {
            awaitingStart = false;
            loaded = true; loading = false; loadDeadline.stop();
            // A second video may keep the same pause/seekability values: no change event is guaranteed.
            observed.forEach((name, i) => send(["get_property", name], 100 + i));
            applyResume();
        } else if (message.event === "end-file") {
            // Replacing a file emits end-file(stop) for the old item AFTER open().
            // It must not cancel the new load or advance the queue twice.
            if (message.reason === "stop" || message.reason === "redirect" || awaitingStart) return;
            if (Number.isInteger(message.playlist_entry_id) && activeEntryId >= 0 && message.playlist_entry_id !== activeEntryId) return;
            awaitingStart = true;
            reset(); loading = false; loadDeadline.stop();
            if (message.reason === "eof") finished();
            if (message.reason === "error") {
                error = "YouTube : " + (message.file_error || lastDiagnostic || "échec de lecture ; vérifiez yt-dlp et votre connexion.");
                playbackFailed(error);
            }
        } else if (message.event === "property-change") {
            const data = message.data;
            switch (message.name) {
            case "time-pos": position = Number.isFinite(data) ? data * 1000 : 0; break;
            case "duration": duration = Number.isFinite(data) ? data * 1000 : 0; break;
            case "pause": paused = data !== false; break;
            case "paused-for-cache": buffering = data === true; break;
            case "seekable": seekable = data === true; break;
            case "media-title":
                if (data) {
                    title = String(data);
                    if (loaded) titleResolved(url, title);
                }
                break;
            case "metadata":
                if (data) artist = String(data.ARTIST || data.artist || data.UPLOADER || data.uploader || "YouTube");
                break;
            }
        }
    }
    onVolumeChanged: if (ipc.connected) send(["set_property", "volume", Math.round(Math.max(0, Math.min(1, volume)) * 100)])
    Component.onDestruction: { if (ipc.connected) send(["quit"]); mpv.running = false; }
    Process {
        id: mpv
        command: ["mpv", "--no-config", "--load-scripts=no", "--no-video", "--idle=yes", "--terminal=no", "--input-terminal=no", "--ytdl=yes", "--ytdl-format=234/233/bestaudio/best", "--volume=" + Math.round(root.volume * 100), "--input-ipc-server=" + root.socketPath]
        stderr: SplitParser { onRead: data => { if (data.trim()) root.lastDiagnostic = data.trim().slice(-500); } }
        onExited: (code, status) => {
            ipc.connected = false;
            const unexpected = root.loading || root.loaded;
            root.reset(); root.loading = false; root.pendingLoad = false; loadDeadline.stop();
            if (unexpected) root.error = "mpv s’est arrêté. " + root.lastDiagnostic;
        }
    }
    Socket {
        id: ipc
        path: root.socketPath
        parser: SplitParser { onRead: data => root.receive(data) }
        onConnectedChanged: {
            if (!connected) return;
            root.attempts = 0;
            root.observed.forEach((name, i) => root.send(["observe_property", i + 1, name]));
            root.loadPending();
        }
    }
    Timer {
        interval: 100; repeat: true; running: mpv.running && !ipc.connected
        onTriggered: {
            if (++root.attempts > 80) {
                root.fail("Connexion à mpv impossible. Vérifiez mpv et l’accès au dossier XDG_RUNTIME_DIR.");
                mpv.running = false;
            } else ipc.connected = true;
        }
    }
    Timer {
        id: loadDeadline; interval: 90000
        onTriggered: root.fail("YouTube ne répond pas. Vérifiez votre connexion et yt-dlp, puis réessayez.")
    }
}
