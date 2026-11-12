import QtQuick
import Quickshell
ShellRoot {
    YoutubeHistory { id: history }
    function check(ok, message) { if (!ok) { console.error("FAIL history: " + message); Qt.exit(1); } }
    function url(i) { return "https://www.youtube.com/watch?v=" + String(i).padStart(11, "0"); }
    Timer {
        interval: 100; running: true
        onTriggered: {
            if (Quickshell.env("CASSETTE_HISTORY_RELOAD") === "1") {
                check(history.entries.length === 10, "persists after restart");
                check(history.entries[0].url === url(4) && history.entries[0].title === "Titre été", "order and title persist");
                console.log("HISTORY RELOAD PASS"); Qt.quit(); return;
            }
            check(history.entries.length === 0, "isolated initial state");
            for (let i = 0; i < 12; i++) history.remember(url(i));
            check(history.entries.length === 10, "limit 10");
            check(history.entries[0].url === url(11) && history.entries[9].url === url(2), "newest first and eviction");
            history.updateTitle(url(4), "Titre été"); history.remember(url(4));
            check(history.entries.length === 10 && history.entries[0].title === "Titre été", "dedup and preserve title");
            check(history.entries.filter(item => item.url === url(4)).length === 1, "no duplicate");
            history.remember("invalid"); history.updateTitle(url(99), "unknown");
            check(history.entries.length === 10 && history.entries[0].url === url(4), "reject invalid");
            console.log("HISTORY PASS: limit, order, dedup, titles, validation"); Qt.quit();
        }
    }
}
