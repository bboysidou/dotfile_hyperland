import QtQuick
import qs.core.helpers

Item {
    id: root

    property var windows: []
    property var hovered: null
    property bool dragging: false

    signal cancelled
    signal accepted
    signal selectAll
    signal restored
    signal annotateToggled
    signal shapeStepped(int delta)
    signal moved(var target)

    function direction(key: int): var {
        if (key === Qt.Key_Left || key === Qt.Key_H)
            return [-1, 0];
        if (key === Qt.Key_Right || key === Qt.Key_L)
            return [1, 0];
        if (key === Qt.Key_Up || key === Qt.Key_K)
            return [0, -1];
        if (key === Qt.Key_Down || key === Qt.Key_J)
            return [0, 1];
        return null;
    }

    focus: true

    Keys.onPressed: event => {
        const dir = root.direction(event.key);
        if (event.key === Qt.Key_Escape)
            root.cancelled();
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            root.accepted();
        else if (event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier))
            root.selectAll();
        else if (event.key === Qt.Key_E && !(event.modifiers & Qt.ControlModifier))
            root.annotateToggled();
        else if (event.key === Qt.Key_R && !root.dragging)
            root.restored();
        else if (event.key === Qt.Key_Backtab)
            root.shapeStepped(-1);
        else if (event.key === Qt.Key_Tab)
            root.shapeStepped(1);
        else if (dir && !root.dragging)
            root.moved(Geom.step(root.windows, root.hovered, dir[0], dir[1]));

        event.accepted = true;
    }
}
