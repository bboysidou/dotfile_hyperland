pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.display.components
import qs.services

ColumnLayout {
    id: root

    property color accent: Colours.tabErrors
    property string filter: root.config.filterAll
    property bool armed: false
    property var open: ({})

    readonly property var config: Appearance.errorLog
    readonly property var shown: ErrorLog.entries.filter(entry => {
        if (root.filter === root.config.filterErrors)
            return LogLevel.isError(entry.level);
        if (root.filter === root.config.filterWarnings)
            return !LogLevel.isError(entry.level);
        return true;
    })
    readonly property var filters: [
        {
            key: root.config.filterAll,
            label: root.config.tabTemplate.arg(root.config.labelAll).arg(ErrorLog.entries.length),
            accent: root.accent
        },
        {
            key: root.config.filterErrors,
            label: root.config.tabTemplate.arg(root.config.labelErrors).arg(ErrorLog.errorCount),
            accent: Colours.critical
        },
        {
            key: root.config.filterWarnings,
            label: root.config.tabTemplate.arg(root.config.labelWarnings).arg(ErrorLog.warnCount),
            accent: Colours.warning
        }
    ]

    function toggle(key: string): void {
        const next = Object.assign({}, root.open);
        if (next[key])
            delete next[key];
        else
            next[key] = true;
        root.open = next;
    }

    spacing: Appearance.settings.listSpacing

    RowLayout {
        Layout.fillWidth: true

        spacing: root.config.toolbarSpacing

        StyledText {
            Layout.fillWidth: true

            text: root.config.hint
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WordWrap
        }

        Chip {
            label: ErrorLog.copied ? root.config.labelCopied : root.config.labelCopyAll
            active: ErrorLog.copied
            accent: root.accent

            onTriggered: ErrorLog.copyAll(root.shown)
        }

        Chip {
            label: root.armed ? root.config.labelConfirm : root.config.labelClear
            active: root.armed
            accent: Colours.critical

            onTriggered: {
                if (root.armed) {
                    ErrorLog.clear();
                    root.open = {};
                }
                root.armed = !root.armed;
            }
        }
    }

    SegmentBar {
        Layout.fillWidth: true

        current: root.filter
        options: root.filters

        onSelected: key => root.filter = key
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            anchors.fill: parent

            visible: root.shown.length > 0
            model: root.shown
            spacing: Appearance.settings.listSpacing
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: ErrorEntry {
                required property var modelData

                width: ListView.view.width
                entry: modelData
                expanded: root.open[modelData.key] === true

                onToggled: root.toggle(modelData.key)
            }
        }

        EmptyState {
            anchors.centerIn: parent

            visible: root.shown.length === 0
            glyph: Icons.check
            title: root.config.emptyTitle
            subtitle: root.config.emptySubtitle
            accent: root.accent
        }
    }

    Timer {
        running: root.armed
        interval: Appearance.settings.confirmTimeout

        onTriggered: root.armed = false
    }
}
