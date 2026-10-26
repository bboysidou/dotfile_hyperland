pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display

ColumnLayout {
    id: root

    property color accent: Colours.accent

    readonly property var config: Appearance.display
    readonly property var draft: DisplayState.draft

    spacing: 0

    OptionRow {
        label: root.config.labelActive

        Toggle {
            accent: root.accent
            checked: !(root.draft?.disabled ?? false)

            onToggled: checked => DisplayState.setActive(checked)
        }

        StyledText {
            visible: DisplayState.enabledCount <= 1 && !(root.draft?.disabled ?? false)
            text: root.config.labelLastActive
            color: Colours.textMuted
        }
    }

    OptionRow {
        label: root.config.labelPosition

        Stepper {
            value: `x ${root.draft?.x ?? 0}`

            onStepped: delta => DisplayState.nudge("x", delta * root.config.positionStep)
        }

        Item {
            width: root.config.sectionSpacing
            height: 1
        }

        Stepper {
            value: `y ${root.draft?.y ?? 0}`

            onStepped: delta => DisplayState.nudge("y", delta * root.config.positionStep)
        }
    }

    OptionRow {
        label: root.config.labelScale

        Repeater {
            model: root.draft ? DisplayState.scales(root.draft.width, root.draft.height) : []

            Chip {
                required property real modelData

                accent: root.accent
                label: root.config.scaleTemplate.arg(Number(modelData.toFixed(2)))
                active: Math.abs(modelData - (root.draft?.scale ?? 1)) < root.config.scaleTolerance

                onTriggered: DisplayState.set("scale", modelData)
            }
        }
    }

    OptionRow {
        label: root.config.labelTransform

        Repeater {
            model: root.config.transforms

            Chip {
                required property var modelData

                accent: root.accent
                label: modelData[0]
                active: (root.draft?.transform ?? 0) === modelData[1]

                onTriggered: DisplayState.set("transform", modelData[1])
            }
        }
    }

    OptionRow {
        label: root.config.labelMirror

        Repeater {
            model: [""].concat(DisplayState.names.filter(name => name !== DisplayState.monitor))

            Chip {
                required property string modelData

                accent: root.accent
                label: modelData || root.config.labelMirrorNone
                active: (root.draft?.mirror ?? "") === modelData

                onTriggered: DisplayState.set("mirror", modelData)
            }
        }
    }
}
