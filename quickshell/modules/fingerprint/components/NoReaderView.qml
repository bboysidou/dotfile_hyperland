import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.modules.settings.components

ColumnLayout {
    id: root

    readonly property var config: Appearance.fingerprint

    spacing: root.config.viewSpacing

    FingerprintGlyph {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: root.config.viewSpacing
        Layout.preferredWidth: root.config.emptyGlyphSize
        Layout.preferredHeight: root.config.emptyGlyphSize

        progress: 1
    }

    StyledText {
        Layout.fillWidth: true

        text: root.config.hintNoReader
        color: Colours.textMuted
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

    CommandLine {
        label: root.config.labelSetup
        command: Commands.fingerprintSetup
    }

    Item {
        Layout.fillHeight: true
    }
}
