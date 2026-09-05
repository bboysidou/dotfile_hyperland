pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.enums

Row {
    id: root

    property int count: 0
    property int dotSize: Appearance.dot.size
    property int dotSpacing: Appearance.dot.spacing
    property color colour: Colours.textBright

    spacing: Appearance.spacing.none

    Repeater {
        model: root.count

        Item {
            id: slot

            property bool grown: false

            implicitWidth: slot.grown ? root.dotSize + root.dotSpacing : 0
            implicitHeight: root.dotSize

            Component.onCompleted: slot.grown = true

            Behavior on implicitWidth {
                Anim {
                    type: AnimType.standardSmall
                }
            }

            Rectangle {
                anchors.centerIn: parent

                implicitWidth: root.dotSize
                implicitHeight: root.dotSize

                radius: Appearance.rounding.full
                color: root.colour

                scale: slot.grown ? 1 : Appearance.dot.scaleFrom
                opacity: slot.grown ? 1 : 0

                Behavior on scale {
                    Anim {
                        type: AnimType.fastSpatial
                    }
                }

                Behavior on opacity {
                    Anim {
                        type: AnimType.fastEffects
                    }
                }
            }
        }
    }
}
