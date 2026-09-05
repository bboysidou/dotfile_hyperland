import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.dashboard.components
import qs.services

ColumnLayout {
    id: root

    spacing: Appearance.dash.cardSpacing

    Marquee {
        Layout.fillWidth: true
        Layout.preferredWidth: 0

        full: Players.trackTitle
        budget: Appearance.dash.detailTitleBudget
        maxLength: Appearance.dash.detailTitleMax
        clip: true
        horizontalAlignment: Text.AlignHCenter
        color: Colours.textBright
        font.pixelSize: Appearance.dash.detailTitleSize
        font.weight: Appearance.font.weightActive
    }

    Marquee {
        Layout.fillWidth: true
        Layout.preferredWidth: 0

        full: Players.trackAlbum
        budget: Appearance.dash.detailTitleBudget
        maxLength: Appearance.dash.detailTitleMax
        clip: true
        horizontalAlignment: Text.AlignHCenter
        color: Colours.textMuted
        font.pixelSize: Appearance.dash.detailAlbumSize
        visible: Players.trackAlbum.length > 0
    }

    Marquee {
        Layout.fillWidth: true
        Layout.preferredWidth: 0

        full: Players.trackArtist
        budget: Appearance.dash.detailTitleBudget
        maxLength: Appearance.dash.detailTitleMax
        clip: true
        horizontalAlignment: Text.AlignHCenter
        color: Colours.text
        font.pixelSize: Appearance.dash.detailArtistSize
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.dash.cardSpacing

        spacing: Appearance.dash.transportSpacing

        IconButton {
            icon: Icons.shuffle
            size: Appearance.dash.transportSize
            active: Players.shuffle
            disabled: !Players.shuffleSupported

            onTriggered: Players.toggleShuffle()
        }

        IconButton {
            icon: Icons.skipPrevious
            size: Appearance.dash.transportSize
            disabled: !Players.canGoPrevious

            onTriggered: Players.previous()
        }

        IconButton {
            icon: Players.playIcon
            size: Appearance.dash.transportPrimarySize
            accent: true
            disabled: !Players.available

            onTriggered: Players.togglePlaying()
        }

        IconButton {
            icon: Icons.skipNext
            size: Appearance.dash.transportSize
            disabled: !Players.canGoNext

            onTriggered: Players.next()
        }

        IconButton {
            icon: Players.loopIcon
            size: Appearance.dash.transportSize
            active: Players.looping
            disabled: !Players.loopSupported

            onTriggered: Players.cycleLoop()
        }
    }

    Slider {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.dash.cardSpacing
        Layout.preferredHeight: Appearance.dash.seekHeight

        value: Players.progress
        enabled: Players.canSeek

        onMoved: value => Players.seek(value)
    }

    RowLayout {
        Layout.fillWidth: true

        spacing: Appearance.dash.seekSpacing

        StyledText {
            text: Fmt.duration(Players.position)
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            text: Fmt.duration(Players.length)
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
        }
    }

    PlayerSelector {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.dash.cardSpacing
    }
}
