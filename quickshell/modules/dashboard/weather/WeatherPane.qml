import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.config
import qs.core.constants
import qs.core.helpers
import qs.modules.dashboard.dash
import qs.services

Item {
    id: root

    property date selected: Time.now

    readonly property var config: Appearance.weather
    readonly property date today: new Date(Time.now.getFullYear(), Time.now.getMonth(), Time.now.getDate())
    readonly property int dayIndex: Math.round((new Date(root.selected.getFullYear(), root.selected.getMonth(), root.selected.getDate()) - root.today) / Ics.dayMs)
    readonly property bool inForecast: root.dayIndex >= 0 && root.dayIndex < Weather.dates.length

    signal focusRequested
    signal focusReleased

    function step(delta: int): void {
        root.selected = new Date(root.selected.getFullYear(), root.selected.getMonth(), root.selected.getDate() + delta);
    }

    implicitWidth: root.config.width
    implicitHeight: root.config.height

    ColumnLayout {
        anchors.fill: parent

        spacing: root.config.spacing

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: root.config.spacing

            CalendarCard {
                Layout.preferredWidth: root.config.calendarWidth
                Layout.alignment: Qt.AlignTop

                selectable: true
                addable: true
                selectedDate: root.selected

                onPicked: day => root.selected = day
                onAdded: Quickshell.execDetached(Commands.calendarNew)
            }

            ClockOrbit {
                Layout.fillWidth: true
                Layout.fillHeight: true

                slots: root.inForecast ? Weather.slots(root.dayIndex, Time.now.getHours()) : []
            }

            Conditions {
                Layout.preferredWidth: root.config.sideWidth
                Layout.fillWidth: false
                Layout.fillHeight: true

                day: root.inForecast ? Weather.day(root.dayIndex) : null
                date: root.selected
                canBack: root.dayIndex > 0
                canForward: root.dayIndex < Weather.dates.length - 1

                onStepped: delta => root.step(delta)
            }
        }

        AgendaStrip {
            Layout.fillWidth: true

            date: root.selected
            today: root.dayIndex === 0

            onFocusRequested: root.focusRequested()
            onFocusReleased: root.focusReleased()
        }
    }
}
