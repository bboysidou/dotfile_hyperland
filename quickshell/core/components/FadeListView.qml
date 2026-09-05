import QtQuick
import QtQuick.Effects
import qs.core.config
import qs.core.enums

ListView {
    id: root

    property real fadeAmount: Appearance.fade.amount
    property real topFadeOpacity: visibleArea.yPosition > 0 ? 0 : 1
    property real bottomFadeOpacity: visibleArea.yPosition + visibleArea.heightRatio < 1 ? 0 : 1

    flickableDirection: Flickable.VerticalFlick
    orientation: ListView.Vertical
    maximumFlickVelocity: Appearance.fade.flickVelocity

    layer.enabled: true
    layer.effect: MultiEffect {
        maskEnabled: true
        maskSpreadAtMin: 1
        maskThresholdMin: 0.5
        maskSource: mask

        Rectangle {
            id: mask

            anchors.fill: parent

            visible: false
            layer.enabled: true

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop {
                    position: 0
                    color: Qt.rgba(0, 0, 0, root.topFadeOpacity)
                }
                GradientStop {
                    position: root.fadeAmount
                    color: Qt.rgba(0, 0, 0, 1)
                }
                GradientStop {
                    position: 1 - root.fadeAmount
                    color: Qt.rgba(0, 0, 0, 1)
                }
                GradientStop {
                    position: 1
                    color: Qt.rgba(0, 0, 0, root.bottomFadeOpacity)
                }
            }
        }
    }

    Behavior on topFadeOpacity {
        Anim {
            type: AnimType.slowEffects
        }
    }

    Behavior on bottomFadeOpacity {
        Anim {
            type: AnimType.slowEffects
        }
    }
}
