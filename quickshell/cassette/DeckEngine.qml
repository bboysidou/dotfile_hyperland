import QtQuick
import QtMultimedia
import Qt.labs.folderlistmodel

Item {
    id: root
    property var tracks: []
    property int index: -1
    property alias player: player
    property alias volume: output.volume
    property string error: ""
    property real resumePosition: -1
    property bool pendingPlay: false
    property bool scanning: false
    readonly property bool playing: player.playbackState === MediaPlayer.PlayingState
    readonly property string title: player.metaData.stringValue(MediaMetaData.Title) || (index >= 0 ? decodeURIComponent(String(tracks[index]).split('/').pop()) : "Insérez une cassette")
    readonly property string artist: player.metaData.stringValue(MediaMetaData.ContributingArtist) || "Artiste inconnu"
    function time(ms) {
        const s = Math.floor(Math.max(0, ms) / 1000);
        return Math.floor(s / 60) + ':' + String(s % 60).padStart(2, '0');
    }
    function load(urls) {
        player.stop(); pendingPlay = false; resumePosition = -1;
        tracks = Array.from(urls, u => String(u));
        index = tracks.length ? 0 : -1; error = "";
        player.source = index >= 0 ? tracks[index] : "";
    }
    function restore(urls, i, ms) {
        load(urls); if (tracks.length) choose(Math.max(0, Math.min(i, tracks.length - 1)), false);
        resumePosition = Math.max(0, Number(ms) || 0); applyResume();
    }
    function applyResume() {
        if (resumePosition >= 0 && player.seekable && (player.mediaStatus === MediaPlayer.LoadedMedia || player.mediaStatus === MediaPlayer.BufferedMedia)) {
            player.position = resumePosition; resumePosition = -1;
        }
    }
    function choose(i, autoplay) {
        if (i < 0 || i >= tracks.length) return;
        player.stop(); resumePosition = -1; index = i; error = "";
        pendingPlay = autoplay; player.source = tracks[index];
        if (autoplay && (player.mediaStatus === MediaPlayer.LoadedMedia || player.mediaStatus === MediaPlayer.BufferedMedia)) { pendingPlay = false; player.play(); }
    }
    function play() { if (index >= 0) player.play(); }
    function stop() { pendingPlay = false; player.stop(); }
    function next() { if (index + 1 < tracks.length) choose(index + 1, true); else stop(); }
    function previous() { if (player.position > 3000) player.position = 0; else choose(Math.max(0, index - 1), playing); }
    function openFolder(url) { scanning = true; folder.folder = url; folder.settle.restart(); }
    AudioOutput { id: output; volume: 0.5 }
    MediaPlayer {
        id: player
        audioOutput: output
        onSeekableChanged: root.applyResume()
        onMediaStatusChanged: {
            root.applyResume();
            if (mediaStatus === MediaPlayer.LoadedMedia && root.pendingPlay) { root.pendingPlay = false; play(); }
            if (mediaStatus === MediaPlayer.EndOfMedia) root.next();
        }
        onErrorOccurred: (code, message) => { root.pendingPlay = false; root.error = message; }
    }
    FolderListModel {
        id: folder
        property alias settle: settle
        showDirs: false
        showHidden: false
        nameFilters: ["*.mp3", "*.flac", "*.ogg", "*.opus", "*.wav", "*.m4a", "*.aac", "*.aiff", "*.wma"]
        sortField: FolderListModel.Name
        onStatusChanged: if (status === FolderListModel.Ready && root.scanning) settle.restart()
    }
    Timer {
        id: settle; interval: 150
        onTriggered: {
            if (folder.status !== FolderListModel.Ready) return;
            const urls = [];
            for (let i = 0; i < folder.count; ++i) urls.push(folder.get(i, "fileUrl"));
            root.load(urls); root.scanning = false;
            if (!urls.length) root.error = "Aucun fichier audio dans ce dossier (sous-dossiers exclus).";
        }
    }
}
