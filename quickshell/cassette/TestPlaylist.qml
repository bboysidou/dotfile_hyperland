import QtQuick
import Quickshell
import "YoutubeUrls.js" as Urls
ShellRoot {
    DeckController { id: deck }
    YoutubePlaylist { id: parser }
    property int stage: 0
    property int ticks: 0
    function check(ok, message) { if (!ok) { console.error("FAIL playlist: " + message); Qt.exit(1); } }
    function event(data) { deck.youtubeBackend.receive(JSON.stringify(data)); }
    Timer {
        id: testTimer
        interval: 100; running: true; repeat: true
        onTriggered: {
            if (++ticks > 60) { console.error('FAIL playlist timeout stage ' + stage); Qt.exit(1); }
            if (stage === 0) {
                check(Urls.normalize('https://www.youtube.com/watch?v=BaW_jenozKc&list=PLDEMO') === 'https://www.youtube.com/playlist?list=PLDEMO', 'playlist priority');
                check(Urls.normalize('https://youtube.com/playlist?list=PLDEMO') === 'https://www.youtube.com/playlist?list=PLDEMO', 'channel playlist URL');
                check(!Urls.normalize('https://youtube.com.evil/playlist?list=PLDEMO'), 'host validation');
                let caught = false; try { parser.parse('{bad'); } catch (_) { caught = true; } check(caught, 'bad JSON');
                deck.openYoutube('https://youtube.com/playlist?list=PLDEMO'); stage++;
            } else if (stage === 1 && deck.tracks.length === 2) {
                check(deck.playlist && deck.index === 0 && deck.sourceTitle === 'Chaîne · Playlist', 'resolver process result');
                check(deck.trackLabel(deck.tracks[1]) === 'Deuxième', 'track titles and private filtering');
                event({event:'file-loaded'}); event({event:'end-file',reason:'eof'});
                check(deck.index === 1, 'automatic next');
                deck.choose(0, false); check(deck.index === 0 && deck.youtubeBackend.pendingPause, 'paused selection');
                event({event:'start-file',playlist_entry_id:5});
                event({event:'file-loaded'});
                event({event:'end-file',reason:'error',file_error:'unavailable',playlist_entry_id:5});
                check(deck.index === 1, 'skip failed track');
                deck.choose(0, false);
                deck.next(); check(deck.index === 1, 'next button');
                deck.previous(); check(deck.index === 0, 'previous button');
                deck.toggleFavorite(deck.sourceUrl, deck.sourceTitle);
                check(deck.isFavorite(deck.sourceUrl), 'favorite playlist');
                deck.toggleFavorite(deck.currentUrl, 'Première'); check(deck.isFavorite(deck.currentUrl), 'favorite video');
                deck.toggleFavorite(deck.currentUrl, 'Première'); check(!deck.isFavorite(deck.currentUrl), 'remove favorite');
                deck.toggleFavorite(deck.currentUrl, 'Première');
                deck.choose(1, false); deck.volume = 0.31;
                deck.youtubeBackend.restore(deck.currentUrl, 'Deuxième', 12000);
                deck.save();
                check(deck.favorites.length === 2, 'favorites independent from history');
                console.log('PLAYLIST PASS: resolver, filtering, queue, autoplay, navigation, favorites, checkpoint'); testTimer.stop(); Qt.quit();
            }
        }
    }
}
