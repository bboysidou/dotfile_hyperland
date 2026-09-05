import QtQuick
import QtQuick.Layouts
import qs.core.config

Flickable {
    id: root

    default property alias content: layout.data

    implicitHeight: layout.implicitHeight

    contentHeight: layout.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: layout

        width: root.width

        spacing: Appearance.control.paneSpacing
    }
}
