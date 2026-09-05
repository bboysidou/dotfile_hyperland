pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    function vertical(event: var): int {
        if (event.key === Qt.Key_Down)
            return 1;
        if (event.key === Qt.Key_Up)
            return -1;
        if (!(event.modifiers & Qt.ControlModifier))
            return 0;
        if (event.key === Qt.Key_J || event.key === Qt.Key_N)
            return 1;
        if (event.key === Qt.Key_K || event.key === Qt.Key_P)
            return -1;

        return 0;
    }

    function horizontal(event: var): int {
        if (event.key === Qt.Key_Right)
            return 1;
        if (event.key === Qt.Key_Left)
            return -1;
        if (!(event.modifiers & Qt.ControlModifier))
            return 0;
        if (event.key === Qt.Key_L)
            return 1;
        if (event.key === Qt.Key_H)
            return -1;

        return 0;
    }
}
