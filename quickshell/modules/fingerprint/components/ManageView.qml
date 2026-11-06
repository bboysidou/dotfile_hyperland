pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.modules.settings.components
import qs.services

Flickable {
    id: root

    readonly property var config: Appearance.fingerprint
    readonly property var enrolled: root.config.fingerLabels.filter(entry => Fingerprint.fingers.includes(entry[0]))

    contentHeight: list.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: list

        width: root.width

        spacing: root.config.viewSpacing

        SettingRow {
            label: root.config.labelReader

            StyledText {
                text: Fingerprint.deviceName || root.config.labelNoName
                color: Colours.textBright
            }
        }

        SettingRow {
            label: root.config.labelSudo

            StyledText {
                text: Fingerprint.sudoEnabled ? root.config.labelOn : root.config.labelOff
                color: Colours.textBright
            }
        }

        CommandLine {
            visible: !Fingerprint.sudoEnabled

            label: root.config.labelSetup
            command: Commands.fingerprintSetup
        }

        StyledText {
            text: root.config.labelEnrolled
            color: Colours.textMuted
        }

        StyledText {
            visible: root.enrolled.length === 0

            text: root.config.labelNone
            color: Colours.text
        }

        Repeater {
            model: root.enrolled

            FingerRow {
                required property var modelData

                finger: modelData[0]
                label: modelData[1]
            }
        }

        StyledText {
            visible: FingerprintEnroll.message.length > 0

            text: FingerprintEnroll.message
            color: Colours.critical
        }

        StyledText {
            text: root.config.labelAdd
            color: Colours.textMuted
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: root.config.chipSpacing

            HandColumn {
                title: root.config.labelLeftHand
                entries: root.config.fingerLabels.slice(0, root.config.handSize)
            }

            HandColumn {
                title: root.config.labelRightHand
                entries: root.config.fingerLabels.slice(root.config.handSize)
            }
        }
    }
}
