pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property MprisPlayer active: null
    property real position: 0

    readonly property bool available: active !== null
    readonly property bool playing: active?.isPlaying ?? false
    readonly property bool paused: active?.playbackState === MprisPlaybackState.Paused
    readonly property string trackTitle: active?.trackTitle ?? ""
    readonly property string trackArtist: active?.trackArtist ?? ""
    readonly property real length: active?.lengthSupported ? active.length : 0
    readonly property string trackAlbum: active?.trackAlbum ?? ""
    readonly property string artUrl: active?.trackArtUrl ?? ""
    readonly property bool canSeek: (active?.canSeek ?? false) && root.length > 0
    readonly property bool canGoNext: active?.canGoNext ?? false
    readonly property bool canGoPrevious: active?.canGoPrevious ?? false
    readonly property real progress: root.length > 0 ? Num.clamp(root.position / root.length, 0, 1) : 0

    readonly property bool shuffle: active?.shuffle ?? false
    readonly property bool shuffleSupported: active?.shuffleSupported ?? false
    readonly property bool loopSupported: active?.loopSupported ?? false
    readonly property int loopState: active?.loopState ?? MprisLoopState.None
    readonly property bool looping: root.loopState !== MprisLoopState.None

    readonly property string loopIcon: {
        if (root.loopState === MprisLoopState.Track)
            return Icons.repeatOnce;
        if (root.loopState === MprisLoopState.Playlist)
            return Icons.repeatAll;
        return Icons.repeatOff;
    }

    readonly property string playIcon: Glyphs.playback(root.playing)

    readonly property var list: Array.from(Mpris.players.values)

    function toggleShuffle(): void {
        if (root.shuffleSupported)
            root.active.shuffle = !root.active.shuffle;
    }

    function cycleLoop(): void {
        if (!root.loopSupported)
            return;

        if (root.loopState === MprisLoopState.None)
            root.active.loopState = MprisLoopState.Playlist;
        else if (root.loopState === MprisLoopState.Playlist)
            root.active.loopState = MprisLoopState.Track;
        else
            root.active.loopState = MprisLoopState.None;
    }

    function label(player): string {
        return player?.identity || player?.desktopEntry || "";
    }

    function select(player): void {
        if (player)
            root.active = player;
    }

    function seek(fraction: real): void {
        if (!root.canSeek)
            return;

        root.active.position = Num.clamp(fraction, 0, 1) * root.length;
        root.sync();
    }

    function reselect(): void {
        const players = Mpris.players.values;
        if (players.includes(root.active))
            return;

        root.active = players.find(player => player.isPlaying) ?? players[0] ?? null;
    }

    function sync(): void {
        root.position = root.active?.positionSupported ? root.active.position : 0;
    }

    function togglePlaying(): void {
        if (root.active?.canTogglePlaying)
            root.active.togglePlaying();
    }

    function previous(): void {
        if (root.active?.canGoPrevious)
            root.active.previous();
    }

    function next(): void {
        if (root.active?.canGoNext)
            root.active.next();
    }

    onActiveChanged: root.sync()

    Instantiator {
        model: Mpris.players

        delegate: QtObject {
            id: watcher

            required property MprisPlayer modelData

            readonly property Connections tracker: Connections {
                target: watcher.modelData

                function onIsPlayingChanged(): void {
                    if (watcher.modelData.isPlaying)
                        root.active = watcher.modelData;
                    root.sync();
                }

                function onPostTrackChanged(): void {
                    root.sync();
                }
            }
        }

        onObjectAdded: root.reselect()
        onObjectRemoved: root.reselect()
    }

    Timer {
        interval: Appearance.bar.mediaPositionInterval
        running: root.playing
        repeat: true

        onTriggered: root.sync()
    }
}
