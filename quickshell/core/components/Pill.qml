import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    default property alias content: layout.data
    property real spacing: Appearance.spacing.small
    property string edge: BarEdge.top
    property int leading: 0
    property int trailing: 0
    property int paddingH: Appearance.bar.pillPaddingH
    property int paddingV: Appearance.bar.pillPaddingV
    property bool interactive: false
    property bool scrollable: false
    property bool secondary: false

    readonly property alias hovered: mouse.containsMouse
    readonly property bool vertical: BarEdge.vertical(root.edge)

    signal clicked
    signal secondaryClicked
    signal scrolled(int delta)

    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignVCenter
    Layout.leftMargin: root.vertical ? 0 : root.leading
    Layout.rightMargin: root.vertical ? 0 : root.trailing
    Layout.topMargin: root.vertical ? root.leading : 0
    Layout.bottomMargin: root.vertical ? root.trailing : 0

    implicitWidth: layout.implicitWidth + (root.vertical ? root.paddingV : root.paddingH) * 2
    implicitHeight: layout.implicitHeight + (root.vertical ? root.paddingH : root.paddingV) * 2

    Component.onCompleted: {
        for (const child of layout.children)
            child.Layout.alignment = Qt.AlignCenter;
    }

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
        GridLayout {
            id: layout

            anchors.centerIn: parent
            flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rows: root.vertical ? -1 : 1
            columns: root.vertical ? 1 : -1
            rowSpacing: root.spacing
            columnSpacing: root.spacing
        }
    ]
}
