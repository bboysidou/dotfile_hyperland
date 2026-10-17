import QtQuick
import qs.core.config

Item {
    id: root

    default property alias content: die.data
    property real contentWidth: 0
    property real contentHeight: 0
    property bool pinned: true

    readonly property real pinSpan: Appearance.hardware.outlineRounding * 2

    implicitWidth: substrate.width + Appearance.hardware.pinLength * 2
    implicitHeight: substrate.height + Appearance.hardware.pinLength * 2

    PinRail {
        anchors.bottom: substrate.top
        anchors.horizontalCenter: substrate.horizontalCenter

        visible: root.pinned
        span: substrate.width - root.pinSpan * 2
    }

    PinRail {
        anchors.top: substrate.bottom
        anchors.horizontalCenter: substrate.horizontalCenter

        visible: root.pinned
        span: substrate.width - root.pinSpan * 2
    }

    PinRail {
        anchors.right: substrate.left
        anchors.verticalCenter: substrate.verticalCenter

        visible: root.pinned
        vertical: true
        span: substrate.height - root.pinSpan * 2
    }

    PinRail {
        anchors.left: substrate.right
        anchors.verticalCenter: substrate.verticalCenter

        visible: root.pinned
        vertical: true
        span: substrate.height - root.pinSpan * 2
    }

    Rectangle {
        id: substrate

        anchors.centerIn: parent

        width: root.contentWidth + (Appearance.hardware.dieInset + Appearance.hardware.artPadding) * 2
        height: root.contentHeight + (Appearance.hardware.dieInset + Appearance.hardware.artPadding) * 2

        color: "transparent"
        radius: Appearance.hardware.outlineRounding
        border.width: Appearance.hardware.outlineWidth
        border.color: Colours.gauge

        DotGrid {
            anchors.fill: parent
            anchors.margins: Appearance.hardware.outlineWidth * 2
        }

        Rectangle {
            anchors.centerIn: parent

            width: root.contentWidth + Appearance.hardware.dieInset * 2
            height: root.contentHeight + Appearance.hardware.dieInset * 2

            color: Colours.surface
            radius: Appearance.hardware.dieRounding
            border.width: Appearance.hardware.dieBorderWidth
            border.color: Colours.border

            Item {
                id: die

                anchors.centerIn: parent

                width: root.contentWidth
                height: root.contentHeight
            }
        }
    }
}
