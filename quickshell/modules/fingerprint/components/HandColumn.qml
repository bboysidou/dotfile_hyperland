pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.modules.fingerprint
import qs.services

ColumnLayout {
    id: root

    required property string title
    required property var entries

    Layout.fillWidth: true
    Layout.preferredWidth: 1

    spacing: Appearance.fingerprint.chipSpacing

    StyledText {
        text: root.title
        color: Colours.textMuted
        font.pixelSize: Appearance.fingerprint.countSize
    }

    Repeater {
        model: root.entries

        Chip {
            required property var modelData

            Layout.fillWidth: true

            label: modelData[2]
            active: Fingerprint.fingers.includes(modelData[0])
            enabled: !active

            onTriggered: FingerprintState.enroll(modelData[0])
        }
    }
}
