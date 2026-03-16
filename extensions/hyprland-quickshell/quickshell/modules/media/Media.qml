// modules/media/Media.qml  — BACKEND ONLY
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.globals

Singleton {
    id: root

    readonly property string moduleType: "custom"

    readonly property var player: {
        let players = Mpris.players.values
        for (let i = 0; i < players.length; i++)
            if (players[i].playbackState === MprisPlaybackState.Playing) return players[i]
        return players.length > 0 ? players[0] : null
    }

    readonly property bool   hasPlayer: player !== null
    readonly property bool   isPlaying: player?.playbackState === MprisPlaybackState.Playing
    readonly property string title:     player ? (player.trackTitle  || player.identity || "") : ""
    readonly property string artist:    player ? (player.trackArtist || "") : ""
    readonly property string album:     player ? (player.trackAlbum  || "") : ""
    readonly property string artUrl:    player ? (player.trackArtUrl || "") : ""

    // Desktop entry — used to detect which player is active (e.g. "spotify")
    readonly property string desktopEntry: player?.desktopEntry ?? ""
    readonly property bool   isSpotify:    desktopEntry.toLowerCase().indexOf("spotify") !== -1

    // Shuffle and loop — only meaningful for players that support them
    readonly property bool   shuffleSupported: player?.shuffleSupported ?? false
    readonly property bool   loopSupported:    player?.loopSupported    ?? false
    readonly property bool   shuffle:          player?.shuffle          ?? false
    readonly property var    loopState:        player?.loopState        ?? MprisLoopState.None

    function toggleShuffle() { if (player && player.shuffleSupported) player.shuffle = !player.shuffle }
    function cycleLoop() {
        if (!player || !player.loopSupported) return
        if (player.loopState === MprisLoopState.None)     player.loopState = MprisLoopState.Track
        else if (player.loopState === MprisLoopState.Track) player.loopState = MprisLoopState.Playlist
        else player.loopState = MprisLoopState.None
    }

    // Both in seconds per the Quickshell docs — property is "length" not "trackLength"
    readonly property real length:   player?.length   ?? 0
    readonly property real position: player?.position ?? 0

    function play()        { player?.play() }
    function pause()       { player?.pause() }
    function toggle()      { isPlaying ? pause() : play() }
    function next()        { player?.next() }
    function prev()        { player?.previous() }

    // Seek to absolute position in seconds by writing player.position directly
    function seekTo(seconds) {
        if (player && player.positionSupported && player.canSeek)
            player.position = Math.max(0, Math.min(seconds, root.length))
    }

    // Format seconds as m:ss
    function fmt(secs) {
        let s = Math.floor(secs || 0)
        if (isNaN(s) || s < 0) s = 0
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0")
    }

    // Emit positionChanged() every second while playing so the binding updates
    property var _ticker: Timer {
        interval: 1000
        running:  root.isPlaying
        repeat:   true
        onTriggered: { if (root.player) root.player.positionChanged() }
    }
}
