import QtQuick
import Quickshell
import "YoutubeUrls.js" as Urls
ShellRoot {
    DeckController { id: deck }
    YoutubePlaylist { id: resolver }
    property int phase: 0
    property int ticks: 0
    function check(ok, message) { if (!ok) { console.error('FAIL mix: ' + message); Qt.exit(1); } }
    Timer {
        id: clock; interval: 100; repeat: true; running: true
        onTriggered: {
            if (++ticks > 50) { clock.stop(); console.error('FAIL mix timeout'); Qt.exit(1); return; }
            const canonical = 'https://www.youtube.com/watch?v=3Ts_DKtzry8&list=RDgngiaY3XE_c';
            if (phase === 0) {
                const input = '+https://www.youtube.com/watch?v=3Ts_DKtzry8&list=RDgngiaY3XE_c&index=2';
                check(Urls.normalize(input) === canonical, 'exact user link retains seed and Mix');
                check(Urls.isPlaylist(canonical) && Urls.isMix(canonical), 'watch URL is a playlist');
                const args = resolver.arguments(canonical);
                check(args.includes('--yes-playlist') && args[args.indexOf('--playlist-end') + 1] === '50', 'bounded Mix extraction');
                check(args[args.length - 1] === canonical, 'direct link sent to yt-dlp');
                check(Urls.normalize('https://youtube.com/playlist?list=RDgngiaY3XE_c') === 'https://www.youtube.com/watch?v=gngiaY3XE_c&list=RDgngiaY3XE_c', 'legacy Mix URL gets a seed');
                deck.open(input); phase++;
            } else if (phase === 1 && deck.tracks.length === 3) {
                check(deck.playlist && deck.sourceUrl === canonical && deck.currentUrl.endsWith('3Ts_DKtzry8'), 'Mix opens at supplied video');
                deck.next(); check(deck.index === 2, 'Mix Next');
                deck.previous(); check(deck.index === 1, 'Mix Previous');
                deck.youtubeBackend.receive(JSON.stringify({event:'start-file',playlist_entry_id:40}));
                deck.youtubeBackend.receive(JSON.stringify({event:'file-loaded'}));
                deck.youtubeBackend.receive(JSON.stringify({event:'end-file',reason:'eof',playlist_entry_id:40}));
                check(deck.index === 2, 'Mix auto-next');
                clock.stop(); console.log('MIX PASS: exact user URL, direct playlist link, bounded extraction, Next and automatic transition'); Qt.quit();
            }
        }
    }
}
