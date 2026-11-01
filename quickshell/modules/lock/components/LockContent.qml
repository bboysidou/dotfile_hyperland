import QtQuick
import qs.core.config

Item {
    id: root

    property bool focused: false

    Identity {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: Appearance.lock.edgeMargin
        anchors.leftMargin: Appearance.lock.edgeMargin
    }

    Criticals {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Appearance.lock.edgeMargin
        anchors.rightMargin: Appearance.lock.edgeMargin
    }

    Column {
        anchors.centerIn: parent

        spacing: Appearance.lock.fieldTopMargin

        Clock {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Password {
            anchors.horizontalCenter: parent.horizontalCenter

            focused: root.focused
        }
    }

    Connectivity {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: Appearance.lock.edgeMargin
        anchors.leftMargin: Appearance.lock.edgeMargin
    }

    MediaChip {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.lock.edgeMargin
    }

    Batteries {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Appearance.lock.edgeMargin
        anchors.rightMargin: Appearance.lock.edgeMargin
    }
}
