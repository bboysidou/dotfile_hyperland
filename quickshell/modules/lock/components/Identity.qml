pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.services

Row {
    id: root

    property string kernel: ""
    property string packages: ""

    spacing: Appearance.lock.identitySpacing

    Icon {
        anchors.verticalCenter: parent.verticalCenter

        text: Icons.arch
        color: Colours.textBright
        font.pixelSize: Appearance.lock.logoSize
        opacity: Appearance.lock.logoOpacity
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter

        StyledText {
            text: Lock.user
            color: Colours.textBright
            font.family: Appearance.lock.labelFont
            font.pixelSize: Appearance.lock.identityFontSize
        }

        StyledText {
            text: root.kernel
            color: Colours.textBright
            font.family: Appearance.lock.labelFont
            font.pixelSize: Appearance.lock.identityFontSize
        }

        StyledText {
            text: root.packages
            color: Colours.textBright
            font.family: Appearance.lock.labelFont
            font.pixelSize: Appearance.lock.identityFontSize
        }
    }

    Process {
        running: true
        command: ["sh", "-c", Commands.kernel]

        stdout: StdioCollector {
            onStreamFinished: root.kernel = text.trim()
        }
    }

    Process {
        running: true
        command: ["sh", "-c", Commands.packageCount]

        stdout: StdioCollector {
            onStreamFinished: root.packages = Appearance.lock.packagesTemplate.arg(text.trim())
        }
    }
}
