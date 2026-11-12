import QtQuick
import QtQuick.Controls
Button {
    id: root
    implicitHeight: 37
    implicitWidth: Math.max(58, label.implicitWidth + 24)
    background: Rectangle {
        radius: 4; border.color: root.activeFocus ? "#7bbda4" : "#65665e"
        gradient: Gradient {
            GradientStop { position: 0; color: root.down ? "#191c19" : "#454941" }
            GradientStop { position: 1; color: "#232822" }
        }
    }
    contentItem: Text {
        id: label; text: root.text; color: root.enabled ? "#d7d7c5" : "#75786b"
        font: root.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }
}
