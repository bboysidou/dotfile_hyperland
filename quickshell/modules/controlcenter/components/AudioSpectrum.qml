pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.helpers

Item {
    id: root

    property var node: null
    property color accent: Colours.audioOutput

    readonly property int count: Appearance.audioPanel.spectrumBars
    readonly property real slot: root.width / Math.max(1, root.count)
    readonly property real barWidth: root.slot * Appearance.audioPanel.spectrumBarRatio

    implicitHeight: Appearance.audioPanel.spectrumHeight
    opacity: Appearance.audioPanel.spectrumOpacity

    CavaFeed {
        id: feed

        running: root.visible && !!root.node
        bars: root.count
        method: Appearance.audioPanel.spectrumMethod
        source: String(root.node?.properties?.[Appearance.audio.serialKey] ?? "")
    }

    Repeater {
        model: root.count

        StyledRect {
            id: bar

            required property int index

            readonly property real value: Num.clamp01(Appearance.audioPanel.spectrumGain * Math.pow(feed.values[bar.index] ?? 0, Appearance.audioPanel.spectrumCurve))

            x: bar.index * root.slot + (root.slot - root.barWidth) / 2
            y: root.height - bar.height
            width: root.barWidth
            height: Appearance.audioPanel.spectrumMinBar + bar.value * (root.height - Appearance.audioPanel.spectrumMinBar)
            topLeftRadius: width / 2
            topRightRadius: width / 2
            color: root.accent

            Behavior on height {
                NumberAnimation {
                    duration: Appearance.audioPanel.spectrumDuration
                }
            }

            Behavior on color {
                CAnim {}
            }
        }
    }
}
