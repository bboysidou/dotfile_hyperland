import QtQuick
import qs.core.config

Rectangle {
    color: Colours.pill
    radius: Appearance.rounding.normal
    antialiasing: true

    Behavior on color {
        CAnim {}
    }
}
