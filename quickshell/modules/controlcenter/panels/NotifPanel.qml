pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter.notifications
import qs.services

Panel {
    id: root

    property string section: NotifSection.all
    property real introHeader: 0
    property real introContent: 0

    readonly property bool unreadOnly: root.section === NotifSection.unread
    readonly property bool criticalOnly: root.section === NotifSection.critical

    readonly property var entries: {
        const all = NotifHistory.toArray();

        if (root.unreadOnly)
            return all.filter(entry => !entry.read);
        if (root.criticalOnly)
            return all.filter(entry => entry.critical);
        return all;
    }

    readonly property var groups: NotifHistory.bucket(root.entries)

    readonly property color accent: root.criticalOnly ? Colours.urgencyCritical : Colours.accent

    readonly property color emphasis: {
        if (root.entries.length === 0)
            return Colours.textMuted;
        return root.criticalOnly ? Colours.urgencyCritical : Colours.textBright;
    }

    readonly property string heroLabel: {
        const config = Appearance.notifPanel;

        if (root.unreadOnly)
            return config.labelUnread.toLowerCase();
        if (root.criticalOnly)
            return config.labelCritical.toLowerCase();
        return config.labelTotal;
    }

    readonly property string heroAction: {
        const config = Appearance.notifPanel;

        if (root.unreadOnly)
            return config.labelMarkRead;
        if (root.criticalOnly)
            return config.labelClearCritical;
        return Appearance.notif.labelClearAll;
    }

    readonly property string emptyTitle: {
        const config = Appearance.notifPanel;

        if (root.unreadOnly)
            return config.emptyUnreadTitle;
        if (root.criticalOnly)
            return config.emptyCriticalTitle;
        return Appearance.notif.emptyTitle;
    }

    readonly property string emptySubtitle: {
        const config = Appearance.notifPanel;

        if (root.unreadOnly)
            return config.emptyUnreadSubtitle;
        if (root.criticalOnly)
            return config.emptyCriticalSubtitle;
        return Appearance.notif.emptySubtitle;
    }

    function purge(): void {
        if (root.unreadOnly)
            NotifHistory.markAllRead();
        else if (root.criticalOnly)
            NotifHistory.clearCritical();
        else
            NotifHistory.clear();
    }

    function step(delta: int): void {
        const values = NotifSection.values;
        root.section = values[Num.wrap(values.indexOf(root.section), delta, values.length)];
    }

    onRevealedChanged: {
        if (root.revealed) {
            intro.restart();
        } else {
            root.introHeader = 0;
            root.introContent = 0;
            root.section = NotifSection.all;
            NotifHistory.markAllRead();
        }
    }

    Keys.onPressed: event => {
        const sections = Nav.horizontal(event);
        if (sections !== 0) {
            root.step(sections);
            event.accepted = true;
        }
    }

    ParallelAnimation {
        id: intro

        SequentialAnimation {
            PauseAnimation {
                duration: Appearance.notifPanel.introHeaderDelay
            }
            NumberAnimation {
                target: root
                property: "introHeader"
                from: 0
                to: 1
                duration: Appearance.notifPanel.introHeaderDuration
                easing.type: Easing.OutBack
                easing.overshoot: Appearance.notifPanel.introOvershoot
            }
        }

        SequentialAnimation {
            PauseAnimation {
                duration: Appearance.notifPanel.introContentDelay
            }
            NumberAnimation {
                target: root
                property: "introContent"
                from: 0
                to: 1
                duration: Appearance.notifPanel.introContentDuration
                easing.type: Easing.OutExpo
            }
        }
    }

    ColumnLayout {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: Appearance.spacing.none

        NotifHero {
            opacity: root.introHeader

            count: root.entries.length
            label: root.heroLabel
            title: Appearance.notif.labelNotifications
            detail: Appearance.notifPanel.countTemplate.arg(NotifHistory.entries.length).arg(NotifHistory.groups.length)
            glyph: root.criticalOnly ? Icons.notifCritical : Icons.notifNormal
            action: root.heroAction
            actionable: root.entries.length > 0
            emphasis: root.emphasis

            transform: Translate {
                y: Appearance.notifPanel.introHeaderLift * (1 - root.introHeader)
            }

            onActivated: root.purge()
        }

        SegmentBar {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.notifPanel.switchTopMargin

            opacity: root.introHeader
            current: root.section
            accent: root.accent
            options: [
                {
                    key: NotifSection.all,
                    label: Appearance.notifPanel.labelAll
                },
                {
                    key: NotifSection.unread,
                    label: Appearance.notifPanel.labelUnread
                },
                {
                    key: NotifSection.critical,
                    label: Appearance.notifPanel.labelCritical
                }
            ]

            transform: Translate {
                y: Appearance.notifPanel.introHeaderLift * (1 - root.introHeader)
            }

            onSelected: key => root.section = key
        }
    }

    PanelBody {
        id: list

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.notifPanel.listTopMargin

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Appearance.notifPanel.groupSpacing
            opacity: root.introContent

            transform: Translate {
                y: Appearance.notifPanel.introContentLift * (1 - root.introContent)
            }

            Repeater {
                model: root.groups

                NotifCard {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true

                    group: modelData
                    position: index
                }
            }
        }
    }

    EmptyState {
        anchors.horizontalCenter: list.horizontalCenter
        anchors.top: list.top
        anchors.topMargin: Appearance.notifPanel.emptyTopMargin

        visible: root.groups.length === 0
        opacity: root.introContent
        glyph: Icons.notifNormal
        title: root.emptyTitle
        subtitle: root.emptySubtitle
    }
}
