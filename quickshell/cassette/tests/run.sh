#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
run_dir=$(mktemp -d /tmp/cassette-check.XXXXXX)
trap 'rm -rf -- "$run_dir"' EXIT
mkdir -p "$run_dir/bin" /tmp/cassette-test-audio
export XDG_RUNTIME_DIR="$run_dir"
export XDG_STATE_HOME="$run_dir/state"
export QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=basic QT_QUICK_CONTROLS_STYLE=Basic QT_QUICK_BACKEND=software
ffmpeg -v error -f lavfi -i 'sine=frequency=440:duration=4' -metadata title='Bande de test' -metadata artist='Arch Test' -y '/tmp/cassette-test-audio/01 été.wav'
ffmpeg -v error -f lavfi -i 'sine=frequency=880:duration=4' -y '/tmp/cassette-test-audio/02.wav'
timeout 20s qs -p TestEngine.qml --no-color 2>&1 | tee "$run_dir/engine.log"
rg -q 'PASS: folder' "$run_dir/engine.log"
# Deterministic Cava substitute: checks stdin configuration on both launches.
cat > "$run_dir/bin/cava" <<'MOCK'
#!/usr/bin/env python3
import sys,time
config=sys.stdin.read()
if '[input]' not in config: sys.exit(1)
print('25;75;',flush=True)
time.sleep(3)
MOCK
chmod +x "$run_dir/bin/cava"
PATH="$run_dir/bin:$PATH" timeout 5s qs -p TestMeters.qml --no-color 2>&1 | tee "$run_dir/meters.log"
rg -q 'METERS PASS' "$run_dir/meters.log"
timeout 5s qs -p TestYoutube.qml --no-color 2>&1 | tee "$run_dir/youtube.log"
rg -q 'YOUTUBE PASS' "$run_dir/youtube.log"
timeout 5s qs -p TestHistory.qml --no-color 2>&1 | tee "$run_dir/history.log"
rg -q 'HISTORY PASS' "$run_dir/history.log"
CASSETTE_HISTORY_RELOAD=1 timeout 5s qs -p TestHistory.qml --no-color 2>&1 | tee "$run_dir/history-reload.log"
rg -q 'HISTORY RELOAD PASS' "$run_dir/history-reload.log"
# Real child-process extraction with deterministic yt-dlp and mpv substitutes.
cat > "$run_dir/bin/yt-dlp" <<'MOCK'
#!/usr/bin/env python3
import json,sys,urllib.parse
if 'RD' in sys.argv[-1]:
 assert '--yes-playlist' in sys.argv and sys.argv[sys.argv.index('--playlist-end')+1] == '50'
 seed=urllib.parse.parse_qs(urllib.parse.urlsplit(sys.argv[-1]).query)['v'][0]
 print(json.dumps({'title':'Mix YouTube','entries':[{'id':'gngiaY3XE_c','title':'Début du Mix'},{'id':seed,'title':'Morceau de départ'},{'id':'BaW_jenozKc','title':'Piste suivante'}]}))
 sys.exit(0)
assert '--flat-playlist' in sys.argv and '--dump-single-json' in sys.argv
print(json.dumps({'title':'Chaîne · Playlist','entries':[
 {'id':'BaW_jenozKc','title':'Première'},
 {'id':'abcdefghijk','title':'[Private video]','availability':'private'},
 {'id':'jNQXAC9IVRw','title':'Deuxième'}]}))
MOCK
cat > "$run_dir/bin/mpv" <<'MOCK'
#!/usr/bin/env python3
import time
time.sleep(10)
MOCK
chmod +x "$run_dir/bin/yt-dlp" "$run_dir/bin/mpv"
PATH="$run_dir/bin:$PATH" timeout 8s qs -p TestPlaylist.qml --no-color 2>&1 | tee "$run_dir/playlist.log"
rg -q 'PLAYLIST PASS' "$run_dir/playlist.log"
timeout 5s qs -p TestSession.qml --no-color 2>&1 | tee "$run_dir/session.log"
rg -q 'SESSION PASS' "$run_dir/session.log"
PATH="$run_dir/bin:$PATH" timeout 8s qs -p TestMix.qml --no-color 2>&1 | tee "$run_dir/mix.log"
rg -q 'MIX PASS' "$run_dir/mix.log"
# Generate and replay actual mpv event ordering, with real local audio and no socket.
export CASSETTE_MPV_EVENT_LOG="$run_dir/mpv-events.jsonl"
timeout 12s /usr/bin/mpv --no-config --no-video --ao=null --idle=yes --terminal=no --load-scripts=no --script=tests/mpv-transitions.lua > "$run_dir/real-mpv.log" 2>&1
timeout 5s qs -p TestMpvEvents.qml --no-color 2>&1 | tee "$run_dir/mpv-replay.log"
rg -q 'REAL MPV EVENTS PASS' "$run_dir/mpv-replay.log"
timeout 5s qs -p TestLocalState.qml --no-color 2>&1 | tee "$run_dir/local-save.log"
rg -q 'LOCAL SAVE PASS' "$run_dir/local-save.log"
CASSETTE_LOCAL_RELOAD=1 timeout 7s qs -p TestLocalState.qml --no-color 2>&1 | tee "$run_dir/local-restore.log"
rg -q 'LOCAL RESTORE PASS' "$run_dir/local-restore.log"
timeout 5s qs -p TestLibrary.qml --no-color 2>&1 | tee "$run_dir/library.log"
rg -q 'LIBRARY PASS' "$run_dir/library.log"
timeout 5s qs -p TestWindowState.qml --no-color 2>&1 | tee "$run_dir/window-save.log"
rg -q 'WINDOW SAVE PASS' "$run_dir/window-save.log"
CASSETTE_WINDOW_RELOAD=1 timeout 5s qs -p TestWindowState.qml --no-color 2>&1 | tee "$run_dir/window-restore.log"
rg -q 'WINDOW RESTORE PASS' "$run_dir/window-restore.log"
timeout 5s qs -p TestVisual.qml --no-color 2>&1 | tee "$run_dir/visual.log"
rg -q 'VISUAL PASS' "$run_dir/visual.log"
/usr/lib/qt6/bin/qmllint --import disable --unresolved-type disable -I /usr/lib/qt6/qml DeckEngine.qml DeckController.qml DeckState.qml YoutubeEngine.qml YoutubeHistory.qml YoutubePlaylist.qml YoutubeLibrary.qml MeterFeed.qml DeckWindow.qml Reel.qml Cassette.qml VuMeter.qml DeckButton.qml DeckSlider.qml
