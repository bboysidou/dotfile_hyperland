import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    default property alias rows: list.data
    property string title: ""
    property string placeholder: ""
    property bool empty: false

    Layout.fillWidth: true

    spacing: Appearance.spacing.none

    StyledText {
        Layout.fillWidth: true
        Layout.preferredHeight: Appearance.hardware.rowHeight

        text: root.title
        color: Colours.textBright
        verticalAlignment: Text.AlignVCenter
    }

    StyledText {
        Layout.leftMargin: Appearance.hardware.listIndent
        Layout.preferredHeight: Appearance.hardware.rowHeight

        visible: root.empty
        text: root.placeholder
        color: Colours.textMuted
        verticalAlignment: Text.AlignVCenter
    }

    ColumnLayout {
        id: list

        Layout.fillWidth: true

        spacing: Appearance.spacing.none
    }
}
