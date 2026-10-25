import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

DetailCard {
    id: root

    readonly property var speed: Appearance.speedTest

    glyph: Icons.check
    title: root.speed.labelDone

    trailing: StyledText {
        text: Qt.formatDateTime(new Date(SpeedTest.finishedAt), root.speed.timeFormat)
        color: Colours.textMuted
        font.pixelSize: root.speed.resultLabelSize
    }

    RowLayout {
        Layout.fillWidth: true

        SpeedReading {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            glyph: Icons.download
            label: root.speed.labelDownload
            mbps: SpeedTest.download
            accent: Colours.audioStream
        }

        SpeedReading {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            glyph: Icons.upload
            label: root.speed.labelUpload
            mbps: SpeedTest.upload
            accent: Colours.audioInput
        }
    }
}
