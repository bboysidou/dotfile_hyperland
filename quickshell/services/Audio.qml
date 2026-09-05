pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool available: sink?.ready ?? false
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int percent: Math.round((sink?.audio?.volume ?? 0) * Appearance.audio.max)

    readonly property var nodes: (Pipewire.nodes?.values ?? []).slice().sort((first, second) => first.id - second.id)
    readonly property var sinks: root.nodes.filter(node => node.isSink && !node.isStream && node.audio)
    readonly property var sources: root.nodes.filter(node => !node.isSink && !node.isStream && node.audio)
    readonly property var streams: root.nodes.filter(node => node.isStream && node.isSink && node.audio)

    function setPercent(value: int): void {
        root.setNodeVolume(root.sink, value);
    }

    function step(delta: int): void {
        root.setPercent(root.percent + delta);
    }

    function label(node): string {
        return node?.nickname || node?.description || node?.name || "";
    }

    function streamLabel(node): string {
        return node?.properties?.["application.name"] || node?.name || "";
    }

    function streamDetail(node): string {
        return node?.properties?.["media.name"] ?? "";
    }

    function nodePercent(node): int {
        return Math.round((node?.audio?.volume ?? 0) * Appearance.audio.max);
    }

    function setNodeVolume(node, value: int): void {
        if (!node?.audio)
            return;

        const clamped = Num.clamp(value, 0, Appearance.audio.max);
        node.audio.volume = clamped / Appearance.audio.max;
    }

    function toggleMute(node): void {
        if (!node?.audio)
            return;

        node.audio.muted = !node.audio.muted;
    }

    function setSink(node): void {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setSource(node): void {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    PwObjectTracker {
        objects: root.sinks.concat(root.sources, root.streams)
    }
}
