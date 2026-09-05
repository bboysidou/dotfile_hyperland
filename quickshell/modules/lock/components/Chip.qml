pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property string glyph
    required property string label

    readonly property int chromeWidth: glyphIcon.implicitWidth + Appearance.lock.statusSpacing + Appearance.lock.statusPaddingH * 2

    implicitWidth: root.chromeWidth + labelText.implicitWidth
    implicitHeight: content.implicitHeight + Appearance.lock.statusPaddingV * 2

    color: Colours.pill
    radius: Appearance.lock.statusRounding

    Row {
        id: content

        anchors.centerIn: parent

        spacing: Appearance.lock.statusSpacing

        Icon {
            id: glyphIcon

            anchors.verticalCenter: parent.verticalCenter

            text: root.glyph
            color: Colours.textBright
            font.pixelSize: Appearance.lock.statusIconSize
        }

        StyledText {
            id: labelText

            anchors.verticalCenter: parent.verticalCenter

            text: root.label
            color: Colours.textBright
            font.family: Appearance.lock.labelFont
            font.pixelSize: Appearance.lock.statusFontSize
        }
    }
}
