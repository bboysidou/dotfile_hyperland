import QtQuick
import Quickshell
ShellRoot {
    DeckController { id: deck }
    property var commands: []
    Connections { target: deck.youtubeBackend; function onCommandSent(command) { commands.push(command); } }
    function check(ok, message) { if (!ok) { console.error('FAIL session: ' + message); Qt.exit(1); } }
    Timer {
        interval: 250; running: true
        onTriggered: {
            check(Math.abs(deck.volume - 0.31) < 0.001, 'volume');
            check(deck.online && deck.playlist && deck.index === 1 && deck.tracks.length === 2, 'source and playlist position');
            check(!deck.playing && !deck.loading && !deck.youtubeBackend.loaded, 'restoration without network/autoplay');
            check(deck.position === 12000 && deck.title === 'Deuxième', 'bookmark and title');
            check(deck.favorites.length === 2 && deck.favorites.some(e => e.title === 'Chaîne · Playlist'), 'favorites persist');
            deck.youtubeBackend.receive(JSON.stringify({event:'file-loaded'}));
            deck.youtubeBackend.receive(JSON.stringify({event:'property-change',name:'seekable',data:true}));
            check(commands.some(c => c[0] === 'seek' && c[1] === 12), 'resume seek after loading');
            console.log('SESSION PASS: persisted volume, source, queue, favorites, bookmark, paused restore'); Qt.quit();
        }
    }
}
