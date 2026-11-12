pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.barlayout
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    title: root.config.labelBar
    glyph: Icons.dashTab

    SettingRow {
        label: root.config.labelBarClock

        SegmentBar {
            width: root.config.segmentWidth

            options: root.config.barClockFormats
            current: Prefs.barClock

            onSelected: key => Prefs.set("barClock", key)
        }
    }

    SettingRow {
        label: root.config.labelWorkspacesAll

        Toggle {
            checked: Prefs.workspacesAll

            onToggled: checked => Prefs.set("workspacesAll", checked)
        }
    }

    SettingRow {
        label: root.config.labelWorkspaceNumbers

        Toggle {
            checked: Prefs.workspaceNumbers

            onToggled: checked => Prefs.set("workspaceNumbers", checked)
        }
    }

    SettingRow {
        Layout.preferredHeight: editButton.implicitHeight
        Layout.bottomMargin: root.config.editLayoutPadding

        label: root.config.labelBarWidgets

        PillButton {
            id: editButton

            glyph: Icons.dashTab
            label: root.config.labelEditLayout

            onTriggered: BarLayoutState.show()
        }
    }
}
