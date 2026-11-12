//@ pragma UseQApplication
import QtQuick
import Quickshell
ShellRoot {
    id: root
    property var win: null
    property Component windowComponent: Component { DeckWindow {} }
    Component.onCompleted: win = windowComponent.createObject(root, Quickshell.env('CASSETTE_WINDOW_RELOAD') === '1' ? {} : {implicitWidth: 740, implicitHeight: 1000})
    Timer {
        interval: 250; running: true
        onTriggered: {
            if (!root.win || root.win.width !== 740 || root.win.height !== 1000) {
                console.error('FAIL window size'); Qt.exit(1); return;
            }
            root.win.saveWindowSize();
            console.log(Quickshell.env('CASSETTE_WINDOW_RELOAD') === '1' ? 'WINDOW RESTORE PASS' : 'WINDOW SAVE PASS');
            Qt.quit();
        }
    }
}
