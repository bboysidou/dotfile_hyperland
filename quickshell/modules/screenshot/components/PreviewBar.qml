pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.enums

Item {
    id: root

    required property var tasks

    signal chosen(string task)

    implicitHeight: row.implicitHeight + Appearance.preview.barPadding * 2

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: Appearance.preview.border
        color: Colours.border
    }

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
