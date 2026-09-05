pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.enums

RowLayout {
    id: root

    required property var tabs

    property string current: ""

    signal selected(string section)

    spacing: Appearance.tab.spacing

    Repeater {
        model: root.tabs

        StyledRect {
            id: tab

            required property var modelData

            readonly property bool active: root.current === tab.modelData.section

            Layout.preferredWidth: (content.implicitWidth || 0) + Appearance.tab.paddingH * 2
            Layout.preferredHeight: Appearance.tab.height

            color: tab.active ? Colours.hover : "transparent"
            radius: Appearance.tab.rounding

            StateLayer {
                radius: parent.radius

                onClicked: root.selected(tab.modelData.section)
            }

            RowLayout {
                id: content

                anchors.centerIn: parent

                spacing: Appearance.tab.iconSpacing

                Icon {
                    text: tab.modelData.icon
                    color: tab.active ? Colours.accent : Colours.textMuted
                    font.pixelSize: Appearance.tab.iconSize
                }

                StyledText {
                    text: tab.modelData.label
                    color: tab.active ? Colours.textBright : Colours.textMuted
                    font.weight: tab.active ? Appearance.font.weightActive : Appearance.font.weightNormal
                }
            }

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: tab.active ? (content.implicitWidth || 0) : 0
                height: Appearance.tab.indicatorHeight
                radius: Appearance.tab.indicatorRounding
                color: Colours.accent

                Behavior on width {
                    Anim {
                        type: AnimType.emphasizedSmall
                    }
                }
            }
        }
    }
}
