import QtQuick
import QtMultimedia
import Quickshell
ShellRoot {
    DeckEngine { id: engine }
    property int stage: 0
    property int ticks: 0
    function check(ok, message) { if (!ok) { console.error("FAIL: " + message); Qt.exit(1); } }
    Timer {
        id: testTimer
        interval: 100; running: true; repeat: true
        onTriggered: {
            ticks++;
            if (ticks > 150) { console.error("FAIL timeout stage " + stage); Qt.exit(1); }
            if (stage === 0) {
                check(engine.time(65000) === "1:05", "time");
                engine.load([]); check(engine.index === -1, "empty playlist");
                engine.next(); engine.previous();
                engine.openFolder("file:///tmp/cassette-test-audio"); stage++;
            } else if (stage === 1 && !engine.scanning && engine.player.duration > 0) {
                check(engine.tracks.length === 2, "folder filtering/count");
                check(engine.player.duration === 4000, "duration");
                check(engine.title === "Bande de test", "title metadata");
                check(engine.artist === "Arch Test", "artist metadata");
                engine.volume = 0.27; check(Math.abs(engine.volume - 0.27) < 0.001, "volume");
                engine.play(); stage++;
            } else if (stage === 2 && engine.playing) {
                engine.player.position = 1500;
                engine.player.pause(); stage++;
            } else if (stage === 3 && engine.player.playbackState === MediaPlayer.PausedState) {
                check(Math.abs(engine.player.position - 1500) < 300, "seek");
                engine.stop(); stage++;
            } else if (stage === 4) {
                check(engine.player.position === 0 && !engine.playing, "stop resets");
                engine.next(); stage++;
            } else if (stage === 5 && engine.index === 1 && engine.playing) {
                engine.previous(); stage++;
            } else if (stage === 6 && engine.index === 0 && engine.playing) {
                engine.choose(1, true); stage++;
            } else if (stage === 7 && engine.index === 1 && engine.playing) {
                engine.player.position = 3900; stage++;
            } else if (stage === 8 && !engine.playing) {
                engine.load(["file:///tmp/cassette-missing.wav"]); stage++;
            } else if (stage === 9 && engine.error.length) {
                console.log("PASS: folder, unicode URL, metadata, duration, volume, play/pause/stop, seek, next/previous, playlist end, invalid file");
                testTimer.stop(); Qt.quit();
            }
        }
    }
}
