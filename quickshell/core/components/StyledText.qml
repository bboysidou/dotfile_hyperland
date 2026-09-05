import QtQuick
import QtQuick.Window
import qs.core.config

Text {
    color: Colours.text
    font.family: Appearance.font.family.sans
    font.pixelSize: Appearance.font.size.normal
    font.weight: Appearance.font.weightNormal
    verticalAlignment: Text.AlignVCenter
    renderType: Screen.devicePixelRatio % 1 === 0 ? Text.NativeRendering : Text.QtRendering

    Behavior on color {
        CAnim {}
    }
}
