pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    readonly property var config: Appearance.settings
    readonly property string switchKey: root.options.find(option => option.startsWith("grp:")) ?? ""

    property bool loaded: false
    property var layouts: []
    property var options: []
    property real sensitivity: 0
    property bool flat: false
    property bool naturalScroll: false
    property bool touchNatural: false
    property bool tapToClick: true
    property bool disableWhileTyping: true
    property bool hasTouchpad: false
    property var available: []
    property var variants: ({})
    property string variantsFor: ""

    function refresh(): void {
        query.running = true;
        devices.running = true;
        if (root.available.length === 0)
            layoutLister.running = true;
    }

    function value(line: string): var {
        try {
            const parsed = JSON.parse(line);
            return parsed.str ?? parsed.float ?? parsed.bool ?? parsed.int ?? null;
        } catch (parseError) {
            return null;
        }
    }

    function adopt(payload: string): void {
        const values = payload.split("\n").filter(line => line.length > 0).map(root.value);
        if (values.length !== Commands.inputOptions.length)
            return;
        const names = String(values[0]).split(",");
        const kinds = String(values[1]).split(",");
        root.layouts = names.filter(name => name.length > 0).map((layout, index) => ({
                    layout,
                    variant: kinds[index] ?? ""
                }));
        root.options = String(values[2]).split(",").filter(option => option.length > 0);
        root.sensitivity = Number(values[3]) || 0;
        root.flat = values[4] === root.config.flatProfile;
        root.naturalScroll = values[5] === true;
        root.touchNatural = values[6] === true;
        root.tapToClick = values[7] === true;
        root.disableWhileTyping = values[8] === true;
        root.loaded = true;
    }

    function set(key: string, value: var): void {
        root[key] = value;
        root.schedule();
    }

    function stepSensitivity(delta: int): void {
        const precision = Math.pow(10, root.config.sensitivityDecimals);
        const next = Math.round((root.sensitivity + delta * root.config.sensitivityStep) * precision) / precision;
        root.set("sensitivity", Num.clamp(next, root.config.sensitivityMin, root.config.sensitivityMax));
    }

    function setSwitchKey(option: string): void {
        root.set("options", root.options.filter(item => !item.startsWith("grp:")).concat(option ? [option] : []));
    }

    function addLayout(layout: string): void {
        if (root.layouts.length >= root.config.maxLayouts || root.layouts.some(entry => entry.layout === layout))
            return;
        root.set("layouts", root.layouts.concat([
            {
                layout,
                variant: ""
            }
        ]));
    }

    function removeLayout(layout: string): void {
        if (root.layouts.length > 1)
            root.set("layouts", root.layouts.filter(entry => entry.layout !== layout));
    }

    function loadVariants(layout: string): void {
        if (root.variants[layout] !== undefined || variantLister.running)
            return;
        root.variantsFor = layout;
        variantLister.command = Commands.keymapVariants.concat([layout]);
        variantLister.running = true;
    }

    function cycleVariant(layout: string, delta: int): void {
        const choices = [""].concat(root.variants[layout] ?? []);
        root.set("layouts", root.layouts.map(entry => {
            if (entry.layout !== layout)
                return entry;
            const next = Num.wrap(choices.indexOf(entry.variant), delta, choices.length);
            return {
                layout,
                variant: choices[next]
            };
        }));
    }

    function clean(text: string): string {
        return text.replace(/[^A-Za-z0-9_:,.-]/g, "");
    }

    function render(): string {
        return root.config.inputTemplate.arg(root.clean(root.layouts.map(entry => entry.layout).join(","))).arg(root.clean(root.layouts.map(entry => entry.variant).join(","))).arg(root.clean(root.options.join(","))).arg(root.sensitivity.toFixed(root.config.sensitivityDecimals)).arg(root.flat ? root.config.flatProfile : "").arg(String(root.naturalScroll)).arg(String(root.touchNatural)).arg(String(root.tapToClick)).arg(String(root.disableWhileTyping));
    }

    function schedule(): void {
        if (root.loaded)
            debounce.restart();
    }

    function apply(): void {
        const code = root.render();
        inputFile.setText(root.config.inputHeader + code);
        evaluator.command = Commands.hyprEval.concat([code]);
        evaluator.running = true;
    }

    Timer {
        id: debounce

        interval: root.config.saveDebounce

        onTriggered: root.apply()
    }

    FileView {
        id: inputFile

        path: Paths.input
        atomicWrites: true
        printErrors: false
    }

    Process {
        id: evaluator
    }

    Process {
        id: query

        command: ["sh", "-c", Commands.inputQuery, "sh"].concat(Commands.inputOptions)

        stdout: StdioCollector {
            onStreamFinished: root.adopt(text)
        }
    }

    Process {
        id: devices

        command: Commands.inputDevices

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.hasTouchpad = JSON.parse(text).mice.some(mouse => mouse.name.includes(root.config.touchpadMatch));
                } catch (parseError) {
                    root.hasTouchpad = false;
                }
            }
        }
    }

    Process {
        id: layoutLister

        command: Commands.keymapLayouts

        stdout: StdioCollector {
            onStreamFinished: root.available = text.split("\n").filter(line => line.length > 0)
        }
    }

    Process {
        id: variantLister

        stdout: StdioCollector {
            onStreamFinished: root.variants = Object.assign({}, root.variants, {
                [root.variantsFor]: text.split("\n").filter(line => line.length > 0)
            })
        }
    }
}
