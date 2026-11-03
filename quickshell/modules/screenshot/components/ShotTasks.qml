pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    required property var tasks

    signal chosen(string task)

    implicitWidth: row.implicitWidth + Appearance.preview.barPadding * 2
    implicitHeight: row.implicitHeight + Appearance.preview.barPadding * 2

    radius: Appearance.preview.barRounding
    color: Qt.alpha(Colours.surface, Appearance.preview.barOpacity)
    border.width: Appearance.preview.border
    border.color: Colours.border

    Row {
        id: row

        anchors.centerIn: parent

        spacing: Appearance.preview.barSpacing

        Repeater {
            model: root.tasks

            EditorButton {
                required property var modelData

                icon: modelData.icon
                label: ShotTask.labels[modelData.task]

                onTriggered: root.chosen(modelData.task)
            }
        }
    }
}
