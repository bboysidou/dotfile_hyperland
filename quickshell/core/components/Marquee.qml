import QtQuick
import qs.core.config
import qs.core.helpers

StyledText {
    id: root

    property string full: ""
    property real budget: 0
    property int offset: 0
    property int maxLength: Appearance.marquee.maxLength

    readonly property real advance: {
        const sample = root.full.length > 0 ? root.full : "0";
        return metrics.advanceWidth(sample) / sample.length;
    }

    readonly property int windowLength: {
        if (root.budget <= 0 || root.advance <= 0)
            return Appearance.marquee.fallbackLength;

        const fitted = Math.floor(root.budget / Math.ceil(root.advance)) - 1;
        return Num.clamp(fitted, Appearance.marquee.minLength, root.maxLength);
    }

    readonly property bool scrolling: root.full.length > root.windowLength

    text: {
        if (!root.scrolling)
            return root.full;

        const padded = root.full + Appearance.marquee.separator;
        return (padded + padded).substr(root.offset, root.windowLength);
    }

    onFullChanged: root.offset = 0
    onWindowLengthChanged: root.offset = 0

    FontMetrics {
        id: metrics

        font: root.font
    }

    Timer {
        interval: Appearance.marquee.interval
        running: root.visible && root.scrolling
        repeat: true

        onTriggered: root.offset = (root.offset + 1) % (root.full.length + Appearance.marquee.separator.length)
    }
}
