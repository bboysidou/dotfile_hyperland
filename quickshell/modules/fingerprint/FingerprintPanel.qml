import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.controlcenter.panels
import qs.modules.fingerprint.components
import qs.services

Panel {
    id: root

    outlineColour: Colours.accent
    implicitWidth: Appearance.fingerprint.width
    scaleFrom: Appearance.fingerprint.scaleFrom

    Keys.onEscapePressed: FingerprintState.hide()

    ColumnLayout {
        anchors.fill: parent

        spacing: Appearance.control.paneSpacing

        PanelHeader {
            glyph: Icons.fingerprint
            title: Appearance.fingerprint.title
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: Fingerprint.present ? 1 : 0

            NoReaderView {}

            ManageView {}
        }
    }
}
