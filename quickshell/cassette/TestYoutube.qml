import QtQuick
import Quickshell
ShellRoot {
    YoutubeEngine { id: youtube }
    DeckController { id: controller }
    property var commands: []
    Connections { target: youtube; function onCommandSent(command) { commands.push(command); } }
    function check(ok, message) { if (!ok) { console.error("FAIL YouTube: " + message); Qt.exit(1); } }
    function event(value) { youtube.receive(JSON.stringify(value)); }
    Timer {
        interval: 100; running: true
        onTriggered: {
            const canonical = "https://www.youtube.com/watch?v=BaW_jenozKc";
            check(youtube.normalize(" https://youtu.be/BaW_jenozKc?t=8 ") === canonical, "short link");
            check(youtube.normalize(canonical + "&list=PL123") === canonical, "remove playlist");
            check(youtube.normalize("https://music.youtube.com/watch?v=BaW_jenozKc") === canonical, "music URL");
            check(youtube.normalize("https://www.youtube.com/shorts/BaW_jenozKc") === canonical, "Shorts");
            check(youtube.normalize("https://www.youtube.com/live/BaW_jenozKc") === canonical, "live");
            for (const bad of ["file:///tmp/a", "https://youtube.com.evil/watch?v=BaW_jenozKc", "https://evil@youtube.com/watch?v=BaW_jenozKc", "https://youtube.com/playlist?list=PL123", "$(touch /tmp/no)", "https://youtu.be/a"]) check(youtube.normalize(bad) === "", "invalid URL " + bad);
            check(!controller.openYoutube("invalid") && !controller.online, "invalid link preserves source");
            event({event: "file-loaded"});
            event({event: "property-change", name: "pause", data: false});
            event({event: "property-change", name: "duration", data: 90});
            event({event: "property-change", name: "time-pos", data: 12.5});
            event({event: "property-change", name: "seekable", data: true});
            event({event: "property-change", name: "media-title", data: "Test YouTube"});
            event({event: "property-change", name: "metadata", data: {ARTIST: "Test Channel"}});
            check(youtube.playing && youtube.duration === 90000 && youtube.position === 12500, "state and milliseconds");
            check(youtube.title === "Test YouTube" && youtube.artist === "Test Channel", "metadata");
            youtube.seek(25000); check(JSON.stringify(commands.pop()) === '["seek",25,"absolute+exact"]', "seek command");
            youtube.pause(); check(youtube.pendingPause, "pause while loading");
            event({event: "property-change", name: "pause", data: true}); check(!youtube.playing, "paused");
            youtube.url = canonical; youtube.play(); check(JSON.stringify(commands.pop()) === '["set_property","pause",false]', "play command");
            event({event: "property-change", name: "pause", data: false});
            event({event: "property-change", name: "paused-for-cache", data: true}); check(!youtube.playing, "buffering stops reels");
            event({event: "property-change", name: "paused-for-cache", data: false}); check(youtube.playing, "buffering recovery");
            youtube.receive("not json");
            youtube.awaitingStart = true; youtube.loading = true;
            event({event: "end-file", reason: "stop", playlist_entry_id: 1});
            check(youtube.loading && youtube.awaitingStart, "old stop cannot cancel next track");
            event({event: "start-file", playlist_entry_id: 2});
            event({event: "file-loaded"});
            event({event: "end-file", reason: "eof", playlist_entry_id: 1});
            check(youtube.loaded, "obsolete EOF cannot skip current track");
            event({event: "end-file", reason: "error", file_error: "Network error"});
            check(!youtube.playing && youtube.error.includes("Network error"), "error feedback");
            youtube.reset();
            event({event: "file-loaded"});
            event({request_id: 102, error: "success", data: false});
            check(youtube.playing, "second video pause property refresh");
            youtube.stop(); check(!youtube.playing, "stop");
            youtube.reset(); check(youtube.position === 0 && !youtube.seekable, "reset");
            event({event: "file-loaded"}); event({event: "end-file", reason: "eof"}); check(!youtube.loaded, "end of video");
            console.log("YOUTUBE PASS: URLs, IPC commands/events, metadata, pause, seek, buffering, errors, end");
            Qt.quit();
        }
    }
}
