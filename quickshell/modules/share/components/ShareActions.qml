import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.share

RowLayout {
    spacing: Appearance.share.actionSpacing

    ShareButton {
        label: Appearance.share.regionLabel
        icon: Icons.shareRegion

        onActivated: ShareState.pickRegion()
    }

    Toggle {
        checked: ShareState.remember

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
        disabled: ShareState.current === null

        onActivated: ShareState.share()
    }
}
