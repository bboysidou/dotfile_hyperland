import QtQuick
import QtQuick.Controls
Slider {
    id: root
    background: Rectangle {
        x: root.leftPadding; y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 150; implicitHeight: 5
        width: root.availableWidth; height: implicitHeight; radius: 2; color: "#363d34"
        Rectangle { width: root.visualPosition * parent.width; height: parent.height; radius: 2; color: "#8db197" }
    }
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 13; implicitHeight: 21; radius: 3
        color: root.pressed ? "#b7d7bd" : "#a4b19b"; border.color: "#2b3329"
    }
}
