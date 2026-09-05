pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.helpers
import qs.services

MouseArea {
    id: root

    property bool controllable: false
    property bool showElapsed: false
    property real availableWidth: 0
    property color accent: Colours.media
    property string fontFamily: Appearance.font.family.sans
    property int fontSize: Appearance.font.size.normal
    property int frameIndex: 0

    readonly property string label: {
        const title = Players.trackTitle;
        const artist = Players.trackArtist;

        if (title.length === 0)
            return "";

        return artist.length > 0 ? title + Appearance.marquee.separator + artist : title;
    }

    readonly property string frameGlyph: {
        if (Players.playing)
            return Icons.mediaFrames[root.frameIndex];
        if (Players.paused)
            return Icons.mediaPaused;
        return "";
    }

    readonly property real titleBudget: root.availableWidth - frame.implicitWidth - (elapsed.visible ? elapsed.implicitWidth : 0) - Appearance.bar.mediaMarginRight * 2

    visible: Players.available && root.label.length > 0
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    enabled: root.controllable
    acceptedButtons: root.controllable ? Qt.LeftButton | Qt.MiddleButton | Qt.RightButton : Qt.NoButton
    cursorShape: root.controllable ? Qt.PointingHandCursor : Qt.ArrowCursor

    onClicked: event => {
        if (event.button === Qt.MiddleButton)
            Players.previous();
        else if (event.button === Qt.RightButton)
            Players.next();
        else
            Players.togglePlaying();
    }

    RowLayout {
        id: layout

        anchors.fill: parent
        spacing: Appearance.spacing.none

        Icon {
            id: frame

            Layout.rightMargin: Appearance.bar.mediaMarginRight

            text: root.frameGlyph
            color: root.accent
            font.pixelSize: root.fontSize
        }

        Marquee {
            id: title

            Layout.rightMargin: root.showElapsed ? Appearance.bar.mediaMarginRight : Appearance.spacing.none

            full: root.label
            budget: root.titleBudget
            color: root.accent
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
        }

        StyledText {
            id: elapsed

            visible: root.showElapsed

            text: `${Fmt.duration(Players.position)}/${Fmt.duration(Players.length)}`
            color: Colours.textMuted
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
        }
    }

    Timer {
        interval: Appearance.bar.mediaFrameInterval
        running: Players.playing
        repeat: true

        onTriggered: root.frameIndex = (root.frameIndex + 1) % Icons.mediaFrames.length
    }
}
