pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display

ColumnLayout {
    id: root

    readonly property var config: Appearance.display

    spacing: root.config.sectionSpacing

    StyledText {
        text: root.config.labelWorkspacesHint.arg(DisplayState.monitor)
        color: Colours.textMuted
    }

    GridLayout {
        columns: root.config.workspaceColumns
        rowSpacing: root.config.gridSpacing
        columnSpacing: root.config.gridSpacing

        Repeater {
            model: root.config.workspaceCount

            StyledRect {
                id: tile

                required property int index

                readonly property string output: DisplayState.assignment[tile.index] ?? ""
                readonly property bool mine: tile.output === DisplayState.monitor

                Layout.preferredWidth: root.config.workspaceTileSize * 2
                Layout.preferredHeight: root.config.workspaceTileSize

                radius: root.config.tileRounding
                color: tile.mine ? Colours.accent : Colours.elevated

                Column {
                    anchors.centerIn: parent

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: tile.index + 1
                        color: tile.mine ? Colours.surface : Colours.textBright
                        font.pixelSize: root.config.tileNameSize
                        font.bold: true
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: tile.output
                        color: tile.mine ? Colours.surface : Colours.textMuted
                        font.pixelSize: root.config.tileSizeSize
                    }
                }

                StateLayer {
                    radius: tile.radius

                    onClicked: DisplayState.assign(tile.index + 1)
                }
            }
        }
    }
}
