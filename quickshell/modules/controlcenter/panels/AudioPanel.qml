pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter.components
import qs.services

Panel {
    id: root

    property string section: AudioSection.outputs
    property real introHeader: 0
    property real introContent: 0

    readonly property bool inputs: root.section === AudioSection.inputs
    readonly property bool streams: root.section === AudioSection.streams

    readonly property color accent: {
        if (root.inputs)
            return Colours.audioInput;
        if (root.streams)
            return Colours.audioStream;
        return Colours.audioOutput;
    }

    readonly property var devices: {
        if (root.inputs)
            return Audio.sources;
        if (root.streams)
            return Audio.streams;
        return Audio.sinks;
    }

    readonly property var hero: {
        if (root.inputs)
            return Audio.source;
        if (root.streams)
            return Audio.streams[0] ?? null;
        return Audio.sink;
    }

    readonly property string heroName: {
        if (!root.hero)
            return Appearance.audioPanel.labelNoDevice;
        return root.streams ? Audio.streamLabel(root.hero) : Audio.label(root.hero);
    }

    readonly property string heroDetail: {
        if (!root.hero)
            return "";
        return root.streams ? Appearance.audioPanel.labelStreamVolume : (root.hero.name ?? "");
    }


    readonly property string glyph: root.inputs ? Icons.microphone : (root.streams ? Icons.musicNote : Icons.speaker)
    readonly property string mutedGlyph: root.inputs ? Icons.microphoneMuted : Icons.volumeMuted

    function activate(node): void {
        if (root.inputs)
            Audio.setSource(node);
        else if (!root.streams)
            Audio.setSink(node);
    }

    function isActive(node): bool {
        if (root.inputs)
            return node === Audio.source;
        if (root.streams)
            return false;
        return node === Audio.sink;
    }

    function step(delta: int): void {
        const values = AudioSection.values;
        root.section = values[Num.wrap(values.indexOf(root.section), delta, values.length)];
    }

    onRevealedChanged: {
        if (root.revealed) {
            intro.restart();
        } else {
            root.introHeader = 0;
            root.introContent = 0;
        }
    }

    Keys.onPressed: event => {
        const sections = Nav.horizontal(event);
        if (sections !== 0) {
            root.step(sections);
            event.accepted = true;
        }
    }

    ParallelAnimation {
        id: intro

        SequentialAnimation {
            PauseAnimation {
                duration: Appearance.audioPanel.introHeaderDelay
            }
            NumberAnimation {
                target: root
                property: "introHeader"
                from: 0
                to: 1
                duration: Appearance.audioPanel.introHeaderDuration
                easing.type: Easing.OutBack
                easing.overshoot: Appearance.audioPanel.introOvershoot
            }
        }

        SequentialAnimation {
            PauseAnimation {
                duration: Appearance.audioPanel.introContentDelay
            }
            NumberAnimation {
                target: root
                property: "introContent"
                from: 0
                to: 1
                duration: Appearance.audioPanel.introContentDuration
                easing.type: Easing.OutExpo
            }
        }
    }

    ColumnLayout {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: Appearance.spacing.none

        AudioHero {
            opacity: root.introHeader

            node: root.hero
            title: root.heroName
            subtitle: root.heroDetail
            accent: root.accent
            glyph: root.glyph
            mutedGlyph: root.mutedGlyph

            transform: Translate {
                y: Appearance.audioPanel.introHeaderLift * (1 - root.introHeader)
            }
        }

        SegmentBar {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.audioPanel.switchTopMargin

            opacity: root.introHeader
            current: root.section
            accent: root.accent
            options: [
                {
                    key: AudioSection.outputs,
                    label: Appearance.audioPanel.labelOutputs
                },
                {
                    key: AudioSection.inputs,
                    label: Appearance.audioPanel.labelInputs
                },
                {
                    key: AudioSection.streams,
                    label: Appearance.audioPanel.labelStreams
                }
            ]

            transform: Translate {
                y: Appearance.audioPanel.introHeaderLift * (1 - root.introHeader)
            }

            onSelected: key => root.section = key
        }
    }

    PanelBody {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.audioPanel.listTopMargin

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Appearance.audioPanel.groupSpacing
            opacity: root.introContent

            transform: Translate {
                y: Appearance.audioPanel.introContentLift * (1 - root.introContent)
            }

            Repeater {
                model: root.devices

                AudioCard {
                    required property var modelData
                    required property int index

                    node: modelData
                    position: index
                    stream: root.streams
                    active: root.isActive(modelData)
                    accent: root.accent
                    glyph: root.glyph
                    mutedGlyph: root.mutedGlyph

                    onActivated: root.activate(modelData)
                }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.card.paddingH

                visible: root.devices.length === 0
                text: Appearance.audioPanel.emptyStreams
                color: Colours.textMuted
                font.pixelSize: Appearance.card.detailSize
            }
        }
    }
}
