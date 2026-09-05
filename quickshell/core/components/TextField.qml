import QtQuick
import qs.core.config
import qs.core.helpers

StyledRect {
    id: root

    readonly property alias text: input.text

    property string placeholder
    property string icon
    property bool gridNavigation: false
    property int echo: TextInput.Normal
    property int paddingV: Appearance.search.paddingV
    property int paddingH: Appearance.search.paddingH
    property int gap: Appearance.search.spacing
    property int iconSize: Appearance.search.iconSize
    property int placeholderSize: Appearance.font.size.normal

    signal edited(string text)
    signal navigate(int delta)
    signal navigateColumn(int delta)
    signal accepted
    signal cancelled

    function setText(value: string): void {
        input.text = value;
    }

    function reset(): void {
        root.setText("");
    }

    function focusInput(): void {
        input.forceActiveFocus();
    }

    color: Colours.trough
    radius: Appearance.rounding.full

    implicitHeight: input.implicitHeight + root.paddingV * 2

    Icon {
        id: glyph

        anchors.left: parent.left
        anchors.leftMargin: root.paddingH
        anchors.verticalCenter: parent.verticalCenter

        text: root.icon
        color: Colours.textMuted
        font.pixelSize: root.iconSize
    }

    TextInput {
        id: input

        anchors.left: glyph.right
        anchors.leftMargin: root.gap
        anchors.right: parent.right
        anchors.rightMargin: root.paddingH
        anchors.verticalCenter: parent.verticalCenter

        color: Colours.text
        selectionColor: Colours.highlight
        selectedTextColor: Colours.surface
        selectByMouse: true
        echoMode: root.echo

        font.family: Appearance.font.family.sans
        font.pixelSize: Appearance.font.size.normal
        font.weight: Appearance.font.weightNormal

        onTextChanged: root.edited(input.text)

        Keys.onPressed: event => {
            const rows = Nav.vertical(event);
            const columns = Nav.horizontal(event);

            if (event.key === Qt.Key_Escape) {
                root.cancelled();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.accepted();
                event.accepted = true;
            } else if (rows !== 0) {
                root.navigate(rows);
                event.accepted = true;
            } else if (root.gridNavigation && columns !== 0) {
                root.navigateColumn(columns);
                event.accepted = true;
            }
        }

        StyledText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            visible: input.text.length === 0
            text: root.placeholder
            color: Colours.textMuted
            font.pixelSize: root.placeholderSize
        }
    }
}
