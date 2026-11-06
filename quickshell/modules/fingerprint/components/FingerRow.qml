import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.services

RowLayout {
    id: root

    required property string finger
    required property string label

    readonly property var config: Appearance.fingerprint

    property bool armed: false

    Layout.fillWidth: true
    Layout.preferredHeight: root.config.chipRowHeight

    spacing: root.config.listSpacing

    StyledText {
        Layout.fillWidth: true

        text: root.label
        color: Colours.text
    }

    Chip {
        label: root.armed ? root.config.labelConfirm : root.config.labelRemove
        active: root.armed
        accent: Colours.critical

        onTriggered: {
            if (root.armed)
                FingerprintEnroll.remove(root.finger);

            root.armed = !root.armed;
        }
    }

    Timer {
        running: root.armed
        interval: root.config.confirmTimeout

        onTriggered: root.armed = false
    }
}
