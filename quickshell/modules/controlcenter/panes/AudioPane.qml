pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.controlcenter.components
import qs.services

Pane {
    id: root

    component GroupLabel: StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.control.rowPaddingH
        Layout.topMargin: Appearance.control.sectionContentSpacing

        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    PaneHeader {
        glyph: Audio.muted ? Icons.volumeMuted : Icons.speaker
        title: Appearance.control.labelAudio
    }

    GroupLabel {
        text: Appearance.control.labelOutput
    }

    Repeater {
        model: Audio.sinks

        AudioDevice {
            required property var modelData

            Layout.fillWidth: true

            node: modelData
            selected: modelData === Audio.sink
            glyph: Icons.speaker
            mutedGlyph: Icons.volumeMuted

            onActivated: Audio.setSink(modelData)
        }
    }

    GroupLabel {
        text: Appearance.control.labelInput
    }

    Repeater {
        model: Audio.sources

        AudioDevice {
            required property var modelData

            Layout.fillWidth: true

            node: modelData
            selected: modelData === Audio.source
            glyph: Icons.microphone
            mutedGlyph: Icons.microphoneMuted

            onActivated: Audio.setSource(modelData)
        }
    }

    GroupLabel {
        visible: Audio.streams.length > 0
        text: Appearance.control.labelStreams
    }

    Repeater {
        model: Audio.streams

        StreamEntry {
            required property var modelData

            Layout.fillWidth: true

            node: modelData
        }
    }
}
