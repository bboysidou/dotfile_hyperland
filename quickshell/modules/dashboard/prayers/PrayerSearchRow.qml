import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property var place

    signal picked

    implicitHeight: Appearance.prayer.optionHeight

    color: "transparent"
    radius: Appearance.prayer.optionRounding

    StateLayer {
        radius: parent.radius

        onClicked: root.picked()
    }

    StyledText {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal

        text: root.place.country ? `${root.place.city}, ${root.place.country}` : root.place.city
        color: Colours.text
        elide: Text.ElideRight
    }
}
