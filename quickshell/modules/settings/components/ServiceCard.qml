import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.services

StyledRect {
    id: root

    required property var entry
    property color accent: Colours.accent

    readonly property var config: Appearance.settings
    readonly property var unitState: Daemons.states[root.entry.id] ?? null
    readonly property var commands: Daemons.commands(root.entry)
    readonly property bool busy: Daemons.busy === root.entry.id
    readonly property bool failed: Daemons.failures[root.entry.id] !== undefined
    readonly property bool installed: Daemons.installed(root.entry.id)
    readonly property bool active: Daemons.active(root.entry.id)
    readonly property string status: {
        if (root.busy)
            return root.config.stateBusy;
        if (root.failed)
            return root.config.stateFailed.arg(Daemons.failures[root.entry.id]);
        if (!root.installed)
            return root.config.stateMissing;
        const running = root.active ? root.config.stateRunning : root.config.stateStopped;
        if (root.entry.kind === ServiceKind.flag || !root.unitState)
            return running;
        const boot = root.unitState.UnitFileState;
        const label = boot === "enabled" ? root.config.stateEnabled : boot === "static" ? root.config.stateStatic : root.config.stateDisabled;
        return running + root.config.stateSeparator + label;
    }

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + root.config.cardPadding * 2

    radius: root.config.cardRounding
    color: Colours.pill

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.config.cardPadding

        spacing: root.config.cardSpacing

        RowLayout {
            Layout.fillWidth: true

            spacing: root.config.headerSpacing

            Icon {
                Layout.preferredWidth: root.config.iconWidth

                text: Icons[root.entry.glyph] ?? Icons.settings
                color: root.active ? root.accent : Colours.textMuted
                font.pixelSize: root.config.iconSize
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 0

                StyledText {
                    Layout.fillWidth: true

                    text: root.entry.title
                    color: Colours.textBright
                    font.weight: Appearance.font.weightActive
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true

                    text: root.status
                    color: root.failed ? Colours.warning : Colours.textMuted
                    font.pixelSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }
            }

            Toggle {
                visible: root.installed
                enabled: !root.busy
                checked: root.active
                accent: root.accent

                onToggled: checked => Daemons.set(root.entry, checked)
            }

            PillButton {
                visible: !root.installed && root.entry.installable
                disabled: root.busy
                accent: true
                tint: root.accent
                glyph: Icons.download
                label: root.config.labelInstall

                onTriggered: Daemons.install(root.entry)
            }
        }

        StyledText {
            Layout.fillWidth: true

            text: root.entry.description
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WordWrap
        }

        CommandLine {
            visible: !root.installed && root.commands.install !== ""
            label: root.config.labelInstall
            accent: root.accent
            command: root.commands.install
        }

        CommandLine {
            label: root.config.labelEnable
            accent: root.accent
            command: root.commands.enable
        }

        CommandLine {
            label: root.config.labelKill
            accent: root.accent
            command: root.commands.kill
        }
    }
}
