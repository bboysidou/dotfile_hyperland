pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.modules.controlcenter.components
import qs.modules.power
import qs.services

Panel {
    id: root

    readonly property var config: Appearance.powerPanel

    readonly property color levelColour: {
        if (!Battery.available || Battery.charging)
            return Colours.accent;
        if (Battery.percent < root.config.criticalPercent)
            return Colours.critical;
        if (Battery.percent < root.config.warningPercent)
            return Colours.warning;
        return Colours.accent;
    }

    readonly property string status: {
        if (!Battery.available)
            return root.config.labelAc;
        if (Battery.full)
            return root.config.labelFull;
        if (Battery.state === UPowerDeviceState.Charging)
            return root.config.labelCharging;
        if (Battery.discharging)
            return root.config.labelDischarging;
        return root.config.labelNotCharging;
    }

    readonly property var actions: [
        {
            action: PowerAction.lock,
            glyph: Icons.lockScreen
        },
        {
            action: PowerAction.suspend,
            glyph: Icons.sleep
        },
        {
            action: PowerAction.reboot,
            glyph: Icons.restart
        },
        {
            action: PowerAction.shutdown,
            glyph: Icons.power
        }
    ]

    readonly property string profile: {
        if (PowerProfiles.profile === PowerProfile.Performance)
            return root.config.profilePerformance;
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return root.config.profileSaver;
        return root.config.profileBalanced;
    }

    readonly property var profiles: [
        {
            key: root.config.profilePerformance,
            label: root.config.profileTemplate.arg(Icons.speedometer).arg(root.config.labelPerformance),
            value: PowerProfile.Performance
        },
        {
            key: root.config.profileBalanced,
            label: root.config.profileTemplate.arg(Icons.scaleBalance).arg(root.config.labelBalanced),
            value: PowerProfile.Balanced
        },
        {
            key: root.config.profileSaver,
            label: root.config.profileTemplate.arg(Icons.leaf).arg(root.config.labelSaver),
            value: PowerProfile.PowerSaver
        }
    ].filter(entry => entry.value !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    function run(action: string): void {
        ControlState.hide();
        PowerState.run(action);
    }

    implicitWidth: Appearance.orbit.panelWidth

    function setProfile(key: string): void {
        const entry = root.profiles.find(candidate => candidate.key === key);
        if (entry)
            PowerProfiles.profile = entry.value;
    }

    ColumnLayout {
        anchors.fill: parent

        spacing: root.config.sectionSpacing

        RowLayout {
            Layout.fillWidth: true

            TimeLeft {
                visible: Battery.available
                seconds: Battery.secondsLeft
            }

            StyledText {
                visible: !Battery.available
                text: root.config.labelTitle
                color: Colours.textBright
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                icon: Icons.logout
                size: Appearance.control.scanIconSize

                onTriggered: root.run(PowerAction.logout)
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            OrbitStage {
                id: stage

                anchors.centerIn: parent

                width: parent.width
                height: Appearance.orbit.stageHeight

                linked: true
                switchable: false
                accent: root.levelColour

                coreContent: Component {
                    BatteryCore {
                        hasBattery: Battery.available
                        percent: Battery.percent
                        charging: Battery.charging
                        status: root.status
                    }
                }
            }

            StrandRing {
                anchors.centerIn: stage

                width: Appearance.orbit.coreSize * root.config.coreRingScale
                height: width

                value: Battery.available ? Battery.percent / Appearance.scale.percent : 1
                colour: root.levelColour
            }
        }

        StyledRect {
            Layout.fillWidth: true
            visible: Brightness.available || Audio.available
            Layout.preferredHeight: sliders.implicitHeight + root.config.sliderCardPadding * 2

            radius: root.config.cardRounding
            color: Colours.elevated

            ColumnLayout {
                id: sliders

                anchors.fill: parent
                anchors.margins: root.config.sliderCardPadding

                spacing: root.config.sliderRowSpacing

                SliderRow {
                    visible: Brightness.available
                    glyph: Icons.brightness
                    value: Brightness.percent / Appearance.scale.percent
                    colour: Colours.accent

                    onMoved: value => Brightness.setPercent(Math.round(value * Appearance.scale.percent))
                }

                SliderRow {
                    visible: Audio.available
                    glyph: Glyphs.volume(Audio.percent, Audio.muted)
                    value: Audio.percent / Appearance.audio.max
                    colour: Colours.audioOutput

                    onMoved: value => Audio.setPercent(Math.round(value * Appearance.audio.max))
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: root.config.actionSpacing

            Repeater {
                model: root.actions

                ActionTile {
                    required property var modelData

                    glyph: modelData.glyph

                    onTriggered: root.run(modelData.action)
                }
            }
        }

        SegmentBar {
            Layout.fillWidth: true

            options: root.profiles
            current: root.profile

            onSelected: key => root.setProfile(key)
        }
    }
}
