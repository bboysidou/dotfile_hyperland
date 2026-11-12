import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
    YoutubeEngine { id: backend }
    property int completions: 0
    Connections { target: backend; function onFinished() { completions++; } }
    function check(ok, message) { if (!ok) { console.error('FAIL real mpv: ' + message); Qt.exit(1); } }
    FileView {
        id: events
        path: Quickshell.env('CASSETTE_MPV_EVENT_LOG')
        blockLoading: true
    }
    Timer {
        interval: 100; running: true
        onTriggered: {
            let starts = 0, stops = 0;
            for (const line of events.text().trim().split('\n')) {
                const event = JSON.parse(line);
                if (event.event === 'test-replace') { backend.reset(); backend.awaitingStart = true; backend.loading = true; continue; }
                backend.receive(line);
                if (event.event === 'start-file') starts++;
                if (event.event === 'end-file' && event.reason === 'stop') { stops++; check(backend.loading, 'old stop must preserve new loading state'); }
            }
            check(starts === 3 && stops === 1 && completions === 2, 'manual Next and two genuine EOF events');
            console.log('REAL MPV EVENTS PASS: manual replacement, stop ordering, automatic transitions, genuine EOF');
            Qt.quit();
        }
    }
}
