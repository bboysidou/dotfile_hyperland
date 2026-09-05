pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property bool active: false

    readonly property int bars: Appearance.dash.visualiserBars
    readonly property string configPath: `${Paths.cache}/${Appearance.state.dir}/cava.conf`

    property var values: new Array(root.bars).fill(0)

    readonly property string config: `[general]
bars = ${root.bars}
framerate = ${Appearance.dash.visualiserFramerate}
lower_cutoff_freq = ${Appearance.dash.visualiserLowFreq}
higher_cutoff_freq = ${Appearance.dash.visualiserHighFreq}

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = ${Appearance.dash.visualiserRange}
channels = mono

[smoothing]
noise_reduction = ${Appearance.dash.visualiserNoiseReduction}
`

    function monstercat(input: var): var {
        const falloff = 1 / Appearance.dash.visualiserFalloff;
        const out = new Array(input.length);
        let carry = 0;

        for (let i = 0; i < input.length; i++) {
            carry = Math.max(input[i], carry * falloff);
            out[i] = carry;
        }

        carry = 0;

        for (let i = input.length - 1; i >= 0; i--) {
            carry = Math.max(input[i], carry * falloff);
            out[i] = Math.max(out[i], carry);
        }

        return out;
    }

    function apply(line: string): void {
        const parts = line.split(";").filter(part => part.length > 0);
        if (parts.length !== root.bars)
            return;

        const raw = parts.map(part => Num.clamp(Number(part) / Appearance.dash.visualiserRange, 0, 1));
        root.values = root.monstercat(raw);
    }

    onActiveChanged: {
        if (!root.active)
            root.values = new Array(root.bars).fill(0);
    }

    Process {
        running: root.active
        command: ["sh", "-c", 'printf "%s" "$1" > "$2" && exec cava -p "$2"', "sh", root.config, root.configPath]

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => root.apply(data)
        }
    }
}
