import QtQuick
import Quickshell
ShellRoot {
    MeterFeed { id: feed; active: true }
    function check(ok, message) { if (!ok) { console.error("FAIL " + message); Qt.exit(1); } }
    Timer { interval: 400; running: true; onTriggered: { check(feed.left === 0.25 && feed.right === 0.75, "stereo parsing"); feed.active = false; } }
    Timer { interval: 600; running: true; onTriggered: { check(feed.left === 0 && feed.right === 0, "meter stop"); feed.active = true; } }
    Timer { interval: 1000; running: true; onTriggered: { check(feed.left === 0.25 && feed.right === 0.75, "meter restart"); console.log("METERS PASS: stereo parsing, stop, restart"); Qt.quit(); } }
}
