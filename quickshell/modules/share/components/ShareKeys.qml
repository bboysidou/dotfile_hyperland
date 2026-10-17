import QtQuick
import qs.core.config
import qs.core.helpers
import qs.modules.share

Item {
    focus: true

    Keys.onPressed: event => {
        const across = Nav.horizontal(event);
        const down = Nav.vertical(event);

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            ShareState.share();
        else if (event.key === Qt.Key_Escape)
            ShareState.cancel();
        else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab)
            ShareState.cycle();
        else if (across !== 0)
            ShareState.step(across);
        else if (down !== 0)
            ShareState.step(down * Appearance.share.columns);

        event.accepted = true;
    }
}
