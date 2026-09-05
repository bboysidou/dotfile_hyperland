import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    property string networkName: ""
    property string error: ""

    signal submitted(string psk)
    signal cancelled

    function reset(): void {
        field.reset();
    }

    function focusInput(): void {
        field.focusInput();
    }

    spacing: Appearance.control.passwordSpacing

    TextField {
        id: field

        Layout.fillWidth: true

        icon: Icons.networkLocked
        placeholder: `${Appearance.control.passwordPlaceholder} - ${root.networkName}`
        echo: TextInput.Password
        paddingV: Appearance.control.passwordPaddingV
        paddingH: Appearance.control.passwordPaddingH
        gap: Appearance.control.passwordSpacing
        iconSize: Appearance.control.iconSize
        placeholderSize: Appearance.font.size.small

        onAccepted: root.submitted(field.text)
        onCancelled: root.cancelled()
    }

    RowLayout {
        Layout.fillWidth: true

        visible: root.error !== ""
        spacing: Appearance.control.rowSpacing

        Icon {
            text: Icons.failure
            color: Colours.critical
            font.pixelSize: Appearance.control.iconSize
        }

        StyledText {
            Layout.fillWidth: true

            text: root.error
            color: Colours.critical
            font.pixelSize: Appearance.font.size.small
            elide: Text.ElideRight
        }
    }
}
