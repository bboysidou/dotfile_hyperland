//@ pragma UseQApplication
import QtQuick
import Quickshell
ShellRoot {
    DeckWindow { id: win }
    Timer {
        interval: 1000; running: true
        onTriggered: win.face.grabToImage(result => {
            result.saveToFile("/tmp/cassette-preview.png"); console.log("VISUAL PASS"); Qt.quit();
        })
    }
}
