//@ pragma UseQApplication
import QtQuick
import Quickshell
ShellRoot {
    DeckController { id: deck }
    FloatingWindow {
        id: win
        implicitWidth: 680; implicitHeight: 880
        color: '#121413'
        YoutubeLibrary {
            id: library; controller: deck; parent: win.contentItem
            anchors.centerIn: parent; width: 580
        }
    }
    Timer { interval: 200; running: true; onTriggered: library.open() }
    Timer {
        interval: 700; running: true
        onTriggered: library.contentItem.grabToImage(result => {
            if (!result.saveToFile('/tmp/cassette-library-preview.png')) { console.error('FAIL library capture'); Qt.exit(1); }
            console.log('LIBRARY PASS'); Qt.quit();
        })
    }
}
