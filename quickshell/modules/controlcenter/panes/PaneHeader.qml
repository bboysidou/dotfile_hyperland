import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string glyph
    property string title
    property Component control: null

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.control.sectionHeaderHeight

    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.control.rowPaddingH
        anchors.rightMargin: Appearance.control.rowPaddingH

        spacing: Appearance.control.sectionHeaderSpacing

        Icon {
            text: root.glyph
            font.pixelSize: Appearance.control.sectionIconSize
            color: Colours.textBright
        }

        StyledText {
            Layout.fillWidth: true

            text: root.title
            color: Colours.textBright
            elide: Text.ElideRight
        }

        Loader {
            active: root.control !== null
            sourceComponent: root.control
        }
    }
}
