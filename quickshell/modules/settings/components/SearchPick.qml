pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.display.components

ColumnLayout {
    id: root

    required property string placeholder
    property var choices: []
    property var exclude: []

    property string search: ""

    readonly property var matches: root.search.trim().length === 0 ? [] : root.choices.filter(choice => !root.exclude.includes(choice) && Str.contains(choice, root.search)).slice(0, Appearance.settings.pickLimit)

    signal picked(string value)
    signal opened

    Layout.fillWidth: true

    spacing: Appearance.settings.pickSpacing

    TextField {
        id: field

        Layout.fillWidth: true

        placeholder: root.placeholder
        icon: Icons.launcherSearch

        onEdited: text => {
            root.search = text;
            root.opened();
        }
        onCancelled: {
            field.reset();
            root.search = "";
        }
    }

    Flow {
        Layout.fillWidth: true

        visible: root.matches.length > 0
        spacing: Appearance.settings.pickSpacing

        Repeater {
            model: root.matches

            Chip {
                required property string modelData

                label: modelData

                onTriggered: {
                    root.picked(modelData);
                    field.reset();
                    root.search = "";
                }
            }
        }
    }
}
