import QtQuick
import Quickshell
ShellRoot {
    DeckController { id: deck }
    property int step: 0
    property int ticks: 0
    function check(ok, message) { if (!ok) { console.error('FAIL local state: ' + message); Qt.exit(1); } }
    Timer {
        id: testTimer
        interval: 100; repeat: true; running: true
        onTriggered: {
            if (++ticks > 50) { console.error('FAIL local state timeout'); Qt.exit(1); }
            if (Quickshell.env('CASSETTE_LOCAL_RELOAD') === '1') {
                if (deck.seekable && deck.duration > 0) {
                    check(!deck.online && !deck.playing && deck.index === 1 && deck.tracks.length === 2, 'queue restored paused');
                    check(Math.abs(deck.position - 700) < 100, 'local seek after loading');
                    check(Math.abs(deck.volume - 0.42) < 0.001, 'local volume');
                    console.log('LOCAL RESTORE PASS'); testTimer.stop(); Qt.quit();
                }
            } else if (step === 0) {
                deck.load(['file:///tmp/cassette-test-audio/01%20%C3%A9t%C3%A9.wav','file:///tmp/cassette-test-audio/02.wav']);
                deck.choose(1, false); step++;
            } else if (step === 1 && deck.seekable && deck.duration > 0) {
                deck.seek(700); deck.volume = 0.42; deck.save();
                console.log('LOCAL SAVE PASS'); testTimer.stop(); Qt.quit();
            }
        }
    }
}
