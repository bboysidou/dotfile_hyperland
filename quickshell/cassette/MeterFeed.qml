import QtQuick
import Quickshell
import Quickshell.Io
Scope {
    id: root
    property bool active: false
    property real left: 0
    property real right: 0
    property string status: "Analyse de la sortie système · Cava"
    // Cava is already installed. Two stereo frequency bands, not calibrated dB VU.
    readonly property string config: "[general]\nbars=2\nframerate=25\n[input]\nmethod=pulse\nsource=auto\n[output]\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=100\nchannels=stereo\n[smoothing]\nnoise_reduction=0.7\n"
    onActiveChanged: if (!active) { left = 0; right = 0; }
    Process {
        running: root.active
        command: ["cava", "-p", "/dev/stdin"]
        stdinEnabled: true
        onStarted: { write(root.config); stdinEnabled = false; }
        onRunningChanged: if (!running) stdinEnabled = true
        stderr: SplitParser { onRead: data => console.warn("Cassette Cava: " + data) }
        stdout: SplitParser {
            onRead: data => {
                const v = data.trim().split(';').filter(s => s.length).map(Number);
                if (v.length >= 2 && v.every(Number.isFinite)) {
                    root.left = Math.max(0, Math.min(1, v[0]/100));
                    root.right = Math.max(0, Math.min(1, v[1]/100));
                }
            }
        }
        onExited: (code, status) => { root.left = 0; root.right = 0; if (code) root.status = "Analyse audio indisponible"; }
    }
}
