pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    readonly property int cellCount: Appearance.dash.calendarColumns * Appearance.dash.calendarRows

    property int monthOffset: 0

    readonly property date anchorDate: new Date(Time.now.getFullYear(), Time.now.getMonth() + root.monthOffset, 1)

    readonly property var cells: {
        const first = root.anchorDate;
        const lead = (first.getDay() + 6) % 7;
        const start = new Date(first.getFullYear(), first.getMonth(), 1 - lead);
        const today = Time.now;
        const out = [];

        for (let i = 0; i < root.cellCount; i++) {
            const cell = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);

            out.push({
                day: cell.getDate(),
                inMonth: cell.getMonth() === first.getMonth(),
                isToday: cell.getFullYear() === today.getFullYear() && cell.getMonth() === today.getMonth() && cell.getDate() === today.getDate()
            });
        }

        return out;
    }

    function shift(delta: int): void {
        const range = Appearance.dash.calendarMonthRange;
        root.monthOffset = Num.clamp(root.monthOffset + delta, -range, range);
    }

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    WheelHandler {
        onWheel: event => root.shift(event.angleDelta.y > 0 ? -1 : 1)
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Appearance.dash.calendarHeaderHeight

            spacing: Appearance.dash.calendarNavSpacing

            StyledText {
                Layout.fillWidth: true

                text: Qt.formatDateTime(root.anchorDate, Appearance.dash.calendarMonthFormat)
                color: Colours.textBright
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            IconButton {
                Layout.preferredWidth: Appearance.dash.calendarNavButtonSize
                Layout.preferredHeight: Appearance.dash.calendarNavButtonSize

                icon: Icons.chevronLeft
                size: Appearance.dash.calendarNavSize
                disabled: root.monthOffset <= -Appearance.dash.calendarMonthRange

                onTriggered: root.shift(-1)
            }

            IconButton {
                Layout.preferredWidth: Appearance.dash.calendarNavButtonSize
                Layout.preferredHeight: Appearance.dash.calendarNavButtonSize

                icon: Icons.calendarMonth
                size: Appearance.dash.calendarNavSize
                accent: root.monthOffset !== 0
                disabled: root.monthOffset === 0

                onTriggered: root.monthOffset = 0
            }

            IconButton {
                Layout.preferredWidth: Appearance.dash.calendarNavButtonSize
                Layout.preferredHeight: Appearance.dash.calendarNavButtonSize

                icon: Icons.chevronRight
                size: Appearance.dash.calendarNavSize
                disabled: root.monthOffset >= Appearance.dash.calendarMonthRange

                onTriggered: root.shift(1)
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: Appearance.dash.calendarColumns
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: Appearance.dash.calendarDayLabels

                StyledText {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: Appearance.dash.calendarHeaderHeight

                    text: modelData
                    color: Colours.textMuted
                    font.pixelSize: Appearance.dash.cardLabelSize
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Repeater {
                model: root.cellCount

                StyledRect {
                    id: cell

                    required property int index

                    readonly property var cellData: root.cells[cell.index]

                    Layout.fillWidth: true
                    Layout.preferredHeight: Appearance.dash.calendarCellSize

                    color: cell.cellData.isToday ? Colours.accent : "transparent"
                    radius: Appearance.dash.calendarCellRounding

                    StyledText {
                        anchors.centerIn: parent

                        text: cell.cellData.day
                        color: cell.cellData.isToday ? Colours.bar : Colours.text
                        opacity: cell.cellData.inMonth ? 1 : Appearance.dash.calendarOtherMonthOpacity
                        font.weight: cell.cellData.isToday ? Appearance.font.weightActive : Appearance.font.weightNormal
                    }
                }
            }
        }
    }
}
