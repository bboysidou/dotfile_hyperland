import QtQuick
import Quickshell.Io
import "YoutubeUrls.js" as Urls

Item {
    id: root
    property string requested: ""
    property string launched: ""
    property bool busy: false
    property int generation: 0
    property int launchedGeneration: -1
    signal resolved(string url, string title, var entries)
    signal failed(string url, string message)
    function cancel() { generation++; requested = ""; busy = false; launch.stop(); deadline.stop(); worker.running = false; }
    function open(url) { cancel(); requested = url; busy = true; launch.restart(); }
    function arguments(url) {
        const args = ["yt-dlp", "--ignore-config", "--yes-playlist", "--flat-playlist", "--dump-single-json", "--skip-download", "--ignore-errors", "--no-warnings", "--socket-timeout", "15", "--retries", "1"];
        // A Mix has no stable end. Bound extraction so dump-single-json can finish.
        if (Urls.isMix(url)) args.push("--playlist-end", "50");
        return args.concat(["--", url]);
    }
    function parse(text) {
        const data = JSON.parse(text);
        if (!Array.isArray(data.entries)) throw Error("Playlist invalide");
        const entries = data.entries.filter(e => e && /^[A-Za-z0-9_-]{11}$/.test(e.id || '') && e.availability !== 'private' && !/^\[(?:Deleted|Private) video\]$/.test(e.title || '')).map(e => ({url: 'https://www.youtube.com/watch?v=' + e.id, title: String(e.title || e.id)}));
        if (!entries.length) throw Error("Aucune vidéo accessible dans cette playlist.");
        return {title: String(data.title || 'Playlist YouTube'), entries: entries};
    }
    Timer {
        id: launch; interval: 30
        onTriggered: {
            if (!root.requested) return;
            if (worker.running) { restart(); return; }
            root.launched = root.requested; root.launchedGeneration = root.generation;
            worker.command = root.arguments(root.launched);
            worker.running = true; deadline.restart();
        }
    }
    Timer {
        id: deadline; interval: 90000
        onTriggered: { const url = root.requested; root.cancel(); root.failed(url, "La playlist ne répond pas. Réessayez ou vérifiez son accès."); }
    }
    Process {
        id: worker
        stdout: StdioCollector { id: output }
        stderr: StdioCollector { id: diagnostic }
        onExited: (code, status) => {
            if (!root.requested || root.requested !== root.launched || root.generation !== root.launchedGeneration) return;
            const url = root.launched;
            deadline.stop(); root.busy = false; root.requested = "";
            try {
                const result = root.parse(output.text);
                root.resolved(url, result.title, result.entries);
            } catch (e) { root.failed(url, "Playlist : " + (code ? diagnostic.text.trim().slice(-350) || "yt-dlp indisponible ou accès refusé." : String(e))); }
        }
    }
}
