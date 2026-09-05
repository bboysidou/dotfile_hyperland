import QtQuick

Item {
    id: root

    signal accepted
    signal cancelled
    signal backspaced
    signal appended(string text)

    focus: true

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            root.accepted();
        else if (event.key === Qt.Key_Escape)
            root.cancelled();
        else if (event.key === Qt.Key_Backspace)
            root.backspaced();
        else if (event.text.length > 0)
            root.appended(event.text);

        event.accepted = true;
    }
}
