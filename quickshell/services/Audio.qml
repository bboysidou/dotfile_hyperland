pragma Singleton

import Quickshell
import Quickshell.Io
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
    readonly property var streams: root.nodes.filter(node => node.isStream && node.isSink && node.audio && node.name !== Appearance.audio.micTestOutput)
    readonly property var outputs: root.sinks.filter(node => !root.isSmartFilter(node))
    readonly property var links: Pipewire.linkGroups?.values ?? []

    property bool micTest: false

    onSourceChanged: root.micTest = false

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

    function isSmartFilter(node): bool {
        return node?.properties?.[Appearance.audio.smartFilterKey] === Appearance.audio.trueValue;
    }

    function routable(node): bool {
        return !!node?.isStream && !node?.properties?.[Appearance.audio.linkGroupKey];
    }

    function streamOutput(stream) {
        const target = root.links.find(group => group.source?.id === stream?.id)?.target ?? null;
        if (!target || root.isSmartFilter(target))
            return root.sink;
        return target;
    }

    function routeStream(stream, target): void {
        if (!stream || !target)
            return;

        const config = Appearance.audio;
        const id = String(stream.id);
        if (target === root.sink) {
            Quickshell.execDetached([config.metadataCommand, config.metadataDelete, id, config.targetKey]);
            Quickshell.execDetached([config.metadataCommand, config.metadataDelete, id, config.legacyTargetKey]);
            return;
        }

        const serial = target.properties?.[config.serialKey];
        if (serial)
            Quickshell.execDetached([config.metadataCommand, id, config.targetKey, String(serial), config.targetType]);
    }

    function setSink(node): void {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setSource(node): void {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    Process {
        running: root.micTest && !!root.source?.name
        command: [Appearance.audio.loopbackCommand, Appearance.audio.loopbackNameFlag, Appearance.audio.micTestName, Appearance.audio.loopbackCaptureFlag, root.source?.name ?? ""]

        onExited: root.micTest = false
    }

    PwObjectTracker {
        objects: root.sinks.concat(root.sources, root.streams)
    }
}
