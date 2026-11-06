import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.modules.fingerprint
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.fingerprint

    readonly property string reader: {
        if (!Fingerprint.installed)
            return root.config.labelMissing;
        if (!Fingerprint.present)
            return root.config.labelNotFound;

        return Fingerprint.deviceName || root.config.labelNoName;
    }

    title: root.config.title
    glyph: Icons.fingerprint

    SettingRow {
        label: root.config.labelReader

        StyledText {
            text: root.reader
            color: Colours.textBright
        }
    }

    SettingRow {
        visible: Fingerprint.present

        label: root.config.labelFingers

        StyledText {
            text: Fingerprint.fingers.length
            color: Colours.textBright
        }
    }

    SettingRow {
        visible: Fingerprint.present

        label: root.config.labelLock

        StyledText {
            text: Fingerprint.enrolled ? root.config.labelOn : root.config.labelOff
            color: Colours.textBright
        }
    }

    SettingRow {
        visible: Fingerprint.present

        label: root.config.labelSudo

        StyledText {
            text: Fingerprint.sudoEnabled ? root.config.labelOn : root.config.labelOff
            color: Colours.textBright
        }
    }

    SettingRow {
        label: root.config.labelManage

        Chip {
            label: root.config.labelOpen

            onTriggered: FingerprintState.show()
        }
    }
}
