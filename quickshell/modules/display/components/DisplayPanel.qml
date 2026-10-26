pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display
import qs.services

RevealCard {
    id: root

    readonly property var config: Appearance.display

    implicitWidth: root.config.width
    implicitHeight: layout.implicitHeight + root.config.padding * 2

    radius: root.config.rounding
    scaleFrom: root.config.scaleFrom

    visible: root.revealed || root.opacity > 0
    focus: root.revealed

    onRevealedChanged: {
        if (root.revealed)
            root.forceActiveFocus();
    }

    Keys.onPressed: event => {
        const shift = event.modifiers & Qt.ShiftModifier;
        const onMode = DisplayState.tab === root.config.tabMode;

        if (event.key === Qt.Key_Escape)
            DisplayState.hide();
        else if (Displays.confirming && event.key === Qt.Key_Y)
            Displays.keep();
        else if (Displays.confirming && event.key === Qt.Key_N)
            Displays.revert();
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            Displays.confirming ? Displays.keep() : DisplayState.apply();
        else if (onMode && event.key === Qt.Key_Left)
            shift ? DisplayState.stepRate(-1) : DisplayState.stepMode(-1);
        else if (onMode && event.key === Qt.Key_Right)
            shift ? DisplayState.stepRate(1) : DisplayState.stepMode(1);
        else
            return;

        event.accepted = true;
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: root.config.padding

        spacing: root.config.sectionSpacing

        StyledText {
            visible: Displays.monitors.length === 0
            text: root.config.labelEmpty
            color: Colours.textMuted
        }

        ArrangementCanvas {
            Layout.fillWidth: true

            visible: Displays.monitors.length > 0
        }

        TabStrip {
            Layout.alignment: Qt.AlignHCenter

            visible: Displays.monitors.length > 0
            current: DisplayState.tab
            tabs: [
                {
                    section: root.config.tabMode,
                    icon: Icons.monitor,
                    label: root.config.labelModeTab
                },
                {
                    section: root.config.tabLayout,
                    icon: Icons.scaleBalance,
                    label: root.config.labelLayoutTab
                },
                {
                    section: root.config.tabColor,
                    icon: Icons.brightness,
                    label: root.config.labelColorTab
                },
                {
                    section: root.config.tabWorkspaces,
                    icon: Icons.dashTab,
                    label: root.config.labelWorkspacesTab
                }
            ]

            onSelected: section => DisplayState.tab = section
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.config.tabHeight

            visible: DisplayState.draft !== null
            currentIndex: [root.config.tabMode, root.config.tabLayout, root.config.tabColor, root.config.tabWorkspaces].indexOf(DisplayState.tab)

            ModeTab {}

            LayoutTab {}

            ColorTab {}

            WorkspacesTab {}
        }

        RowLayout {
            Layout.fillWidth: true

            visible: Displays.monitors.length > 0
            spacing: root.config.buttonSpacing

            ScrollText {
                Layout.fillWidth: true

                text: Displays.confirming ? root.config.keepTemplate.arg(Displays.countdown) : DisplayState.monitor + (DisplayState.current ? `  ·  ${DisplayState.current.description}` : "")
                color: Displays.confirming ? Colours.warning : Colours.textMuted
            }

            PillButton {
                visible: Displays.confirming
                glyph: Icons.undo
                label: root.config.labelRevert

                onTriggered: Displays.revert()
            }

            PillButton {
                visible: Displays.confirming
                accent: true
                glyph: Icons.check
                label: root.config.labelKeep

                onTriggered: Displays.keep()
            }

            PillButton {
                visible: !Displays.confirming
                accent: true
                disabled: !DisplayState.changed
                glyph: Icons.monitor
                label: root.config.labelApply

                onTriggered: DisplayState.apply()
            }
        }
    }
}
