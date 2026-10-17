import QtQuick
import QtQuick.Layouts
import qs.core.config

StyledRect {
    id: root

    default property alias content: layout.data
    property alias spacing: layout.spacing
    property int paddingH: Appearance.bar.pillPaddingH
    property int paddingV: Appearance.bar.pillPaddingV
    property bool interactive: false
    property bool scrollable: false
    property bool secondary: false

    readonly property alias hovered: mouse.containsMouse

    signal clicked
    signal secondaryClicked
    signal scrolled(int delta)

    implicitWidth: layout.implicitWidth + paddingH * 2
    implicitHeight: layout.implicitHeight + paddingV * 2

    data: [
        StateLayer {
            id: mouse

            disabled: !root.interactive
            acceptedButtons: root.secondary ? Qt.LeftButton | Qt.RightButton : Qt.LeftButton

            onClicked: event => event.button === Qt.RightButton ? root.secondaryClicked() : root.clicked()

            WheelHandler {
                enabled: root.scrollable

                onWheel: event => root.scrolled(event.angleDelta.y)
            }
        },
        RowLayout {
            id: layout

            anchors.centerIn: parent
            spacing: Appearance.spacing.small
        }
    ]
}
