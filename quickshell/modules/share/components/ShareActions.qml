import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.share

RowLayout {
    id: root

    property color accent: Colours.accent

    spacing: Appearance.share.actionSpacing

    ShareButton {
        label: Appearance.share.regionLabel
        icon: Icons.shareRegion

        onActivated: ShareState.pickRegion()
    }

    Toggle {
        checked: ShareState.remember
        accent: root.accent

        onToggled: checked => ShareState.remember = checked
    }

    StyledText {
        Layout.fillWidth: true

        text: Appearance.share.rememberLabel
        color: Colours.textMuted
        font.pixelSize: Appearance.share.bodySize
    }

    ShareButton {
        label: Appearance.share.cancelLabel

        onActivated: ShareState.cancel()
    }

    ShareButton {
        label: Appearance.share.shareLabel
        accent: true
        tint: root.accent
        disabled: ShareState.current === null

        onActivated: ShareState.share()
    }
}
