pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.enums
import qs.modules.display

OptionRow {
    id: root

    readonly property var config: Appearance.display
    readonly property var options: [
        {
            kind: DisplayArrangement.extend,
            output: "",
            label: root.config.labelExtend
        },
        {
            kind: DisplayArrangement.mirror,
            output: DisplayState.mirrorSource,
            label: root.config.mirrorTemplate.arg(DisplayState.mirrorSource)
        }
    ].concat(DisplayState.names.map(name => ({
                kind: DisplayArrangement.only,
                output: name,
                label: root.config.onlyTemplate.arg(name)
            })))

    label: root.config.labelArrangement

    Repeater {
        model: root.options

        Chip {
            required property var modelData

            label: modelData.label
            active: DisplayState.arrangement.kind === modelData.kind && (modelData.kind === DisplayArrangement.extend || DisplayState.arrangement.output === modelData.output)

            onTriggered: DisplayState.arrange(modelData.kind, modelData.output)
        }
    }
}
