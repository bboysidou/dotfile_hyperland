import QtQuick
import qs.core.config

Rectangle {
    implicitWidth: Appearance.editor.dividerWidth
    implicitHeight: Appearance.editor.toolbarHeight - Appearance.editor.dividerInset * 2

    color: Colours.border
}
