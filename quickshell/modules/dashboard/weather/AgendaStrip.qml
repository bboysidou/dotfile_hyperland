pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.helpers
import qs.services

ColumnLayout {
    id: root

    property date date: new Date()
    property bool today: true
    property color accent: Colours.accent

    readonly property var config: Appearance.weather
    readonly property var events: Agenda.events.length >= 0 ? Agenda.on(root.date) : []

    signal focusRequested
    signal focusReleased

    function timeOf(event): string {
        if (event.allDay)
            return root.config.labelAllDay;
        return root.config.rangeTemplate.arg(Qt.formatDateTime(event.start, root.config.eventTimeFormat)).arg(Qt.formatDateTime(event.end, root.config.eventTimeFormat));
    }

    spacing: root.config.agendaSpacing

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.config.agendaHeaderHeight

        spacing: root.config.agendaPadding

        Icon {
            text: Icons.calendarDay
            color: root.accent
        }

        StyledText {
            Layout.fillWidth: true

            readonly property string label: Qt.formatDateTime(root.date, root.config.agendaDateFormat)

            text: root.today ? root.config.todayTemplate.arg(label) : label
            color: Colours.textBright
        }

        PillButton {
            glyph: Icons.openInNew
            label: root.config.labelOpenWeb

            onTriggered: Launch.app(Commands.calendar)
        }
    }

    TextField {
        Layout.preferredWidth: root.config.urlFieldWidth

        visible: Agenda.loaded && !Agenda.configured
        placeholder: root.config.labelUrl
        icon: Icons.calendarPlus

        onActivated: root.focusRequested()
        onAccepted: {
            Agenda.setUrl(text);
            root.focusReleased();
        }
        onCancelled: root.focusReleased()
    }

    StyledText {
        visible: Agenda.configured && root.events.length === 0
        text: root.config.labelNoEvents
        color: Colours.textMuted
    }

    Flickable {
        Layout.fillWidth: true
        Layout.preferredHeight: root.config.agendaCardHeight

        visible: root.events.length > 0
        contentWidth: cards.implicitWidth
        clip: true
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds

        Row {
            id: cards

            Repeater {
                model: root.events

                AgendaCard {
                    required property var modelData

                    title: modelData.summary
                    time: root.timeOf(modelData)
                    place: modelData.location
                }
            }
        }
    }
}
