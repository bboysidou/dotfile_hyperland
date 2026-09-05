import QtQuick
import QtQuick.Layouts
import qs.core.config

Item {
    id: root

    property real value: 0
    property real secondaryValue: 0

    property string icon: ""
    property string primary: ""
    property string label: ""
    property string secondary: ""
    property string secondaryLabel: ""

    property int size: Appearance.gauge.size
    property color colour: Colours.accent
    property color trackColour: Qt.alpha(root.colour, Appearance.gauge.trackOpacity)
    property real secondaryShade: Appearance.gauge.secondaryShade
    property color secondaryColour: Colours.shade(root.colour, root.secondaryShade)
    property color secondaryTrackColour: Qt.alpha(root.secondaryColour, Appearance.gauge.trackOpacity)
    property color primaryColour: Colours.textBright
    property color iconColour: root.colour
    property color labelColour: Colours.textMuted

    property real lowerStart: Appearance.gauge.lowerStart
    property real upperStart: Appearance.gauge.upperStart
    property real halfSpan: Appearance.gauge.halfSpan
    property real textGap: Appearance.gauge.textGap
    property real textRadiusRatio: Appearance.gauge.textRadiusRatio

    property real strokeWidth: root.size * Appearance.gauge.strokeRatio
    property real gapSpacing: root.size * Appearance.gauge.spacingRatio
    property int allowance: Math.round(root.size * Appearance.gauge.allowanceRatio)
    property int valueSize: Math.round(root.size * Appearance.gauge.valueRatio)
    property int iconSize: Math.round(root.size * Appearance.gauge.iconRatio)
    property int labelSize: Math.round(root.size * Appearance.gauge.labelRatio)
    property int secondarySize: Math.round(root.size * Appearance.gauge.secondaryRatio)
    property int centreSpacing: Math.round(root.size * Appearance.gauge.centreSpacingRatio)

    implicitWidth: root.size + root.allowance * 2
    implicitHeight: root.size

    component Half: GaugeArc {
        anchors.centerIn: parent

        width: root.size
        height: root.size

        span: root.halfSpan
        strokeWidth: root.strokeWidth
        gapSpacing: root.gapSpacing
        fgColour: root.colour
        bgColour: root.trackColour
    }

    Half {
        value: root.value
        startAngle: root.lowerStart
    }

    Half {
        value: root.secondaryValue
        startAngle: root.upperStart
        trimEnd: root.textGap
        fgColour: root.secondaryColour
        bgColour: root.secondaryTrackColour
    }

    ColumnLayout {
        anchors.centerIn: parent

        spacing: root.centreSpacing

        Icon {
            Layout.alignment: Qt.AlignHCenter

            text: root.icon
            color: root.iconColour
            font.pixelSize: root.iconSize
            visible: root.icon.length > 0
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter

            text: root.primary
            color: root.primaryColour
            font.pixelSize: root.valueSize
            font.weight: Appearance.font.weightActive
            visible: root.primary.length > 0
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter

            text: root.label
            color: root.labelColour
            font.pixelSize: root.labelSize
            visible: root.label.length > 0
        }
    }

    ColumnLayout {
        id: opening

        readonly property real angle: (root.upperStart + root.halfSpan - root.textGap / 2) * Math.PI / 180
        readonly property real ringRadius: (root.size - root.strokeWidth) / 2 * root.textRadiusRatio

        x: root.width / 2 + opening.ringRadius * Math.cos(opening.angle) - width / 2
        y: root.height / 2 + opening.ringRadius * Math.sin(opening.angle) - height / 2

        spacing: 0

        StyledText {
            Layout.alignment: Qt.AlignHCenter

            text: root.secondary
            color: root.primaryColour
            font.pixelSize: root.secondarySize
            font.weight: Appearance.font.weightActive
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter

            text: root.secondaryLabel
            color: root.labelColour
            font.pixelSize: root.secondarySize
        }
    }
}
