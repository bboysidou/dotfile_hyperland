pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.modules.keybinds.components
import qs.services

Scope {
    id: root

    GlobalShortcut {
        appid: Ids.appid
        name: "keybinds"

        onPressed: KeybindsState.toggle()
    }

    IpcHandler {
        target: "keybinds"

        function open(): string {
            KeybindsState.show();
            return IpcStatus.open;
        }

        function close(): string {
            KeybindsState.hide();
            return IpcStatus.closed;
        }

        function toggle(): string {
            KeybindsState.toggle();
            return KeybindsState.opened ? IpcStatus.open : IpcStatus.closed;
        }

        function status(): string {
            return `opened=${KeybindsState.opened} binds=${Keybinds.count}`;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData

            readonly property bool active: KeybindsState.opened
            readonly property bool primary: KeybindsState.screen === panel.modelData.name

            screen: panel.modelData
            color: "transparent"
            visible: panel.active || content.opacity > 0

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: panel.primary ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            onVisibleChanged: {
                if (panel.visible && panel.primary)
                    keys.forceActiveFocus();
            }

            Item {
                id: content

                anchors.fill: parent

                opacity: panel.active ? 1 : 0

                Behavior on opacity {
                    Anim {
                        type: panel.active ? Appearance.keybinds.fadeInType : Appearance.keybinds.fadeOutType
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: KeybindsState.hide()
                }

                StyledRect {
                    id: card

                    anchors.centerIn: parent

                    visible: panel.primary
                    implicitWidth: Appearance.keybinds.width
                    implicitHeight: Math.min(inner.implicitHeight + Appearance.keybinds.padding * 2, panel.height * Appearance.keybinds.maxHeightRatio / 100)

                    color: Colours.surface
                    radius: Appearance.keybinds.rounding
                    border.width: Appearance.keybinds.borderWidth
                    border.color: Colours.border

                    scale: panel.active ? 1 : Appearance.keybinds.scaleFrom

                    Behavior on scale {
                        Anim {
                            type: AnimType.fastSpatial
                        }
                    }

                    Elevation {
                        anchors.fill: parent

                        level: Appearance.elevation.panel
                        radius: card.radius
                        z: -1
                    }

                    EmptyState {
                        anchors.centerIn: parent

                        visible: Keybinds.count === 0
                        glyph: Icons.keyboard
                        title: Appearance.keybinds.emptyTitle
                        subtitle: Appearance.keybinds.emptySubtitle
                    }

                    ColumnLayout {
                        id: inner

                        anchors.fill: parent
                        anchors.margins: Appearance.keybinds.padding

                        visible: Keybinds.count > 0
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.bottomMargin: Appearance.keybinds.headerBottomMargin

                            spacing: Appearance.keybinds.headerSpacing

                            Icon {
                                text: Icons.keyboard
                                color: Colours.accent
                                font.pixelSize: Appearance.keybinds.headerIconSize
                            }

                            StyledText {
                                text: Appearance.keybinds.title
                                color: Colours.textBright
                                font.pixelSize: Appearance.keybinds.titleSize
                                font.weight: Appearance.font.weightActive
                            }

                            StyledText {
                                Layout.fillWidth: true

                                text: Appearance.keybinds.countTemplate.arg(Keybinds.count)
                                color: Colours.textMuted
                                font.pixelSize: Appearance.keybinds.countSize
                            }

                            StyledText {
                                text: Appearance.keybinds.hint
                                color: Colours.textMuted
                                font.pixelSize: Appearance.keybinds.countSize
                            }
                        }

                        Flickable {
                            id: body

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: spread.implicitHeight

                            clip: true
                            contentWidth: body.width
                            contentHeight: spread.implicitHeight
                            flickableDirection: Flickable.VerticalFlick

                            RowLayout {
                                id: spread

                                width: body.width

                                spacing: Appearance.keybinds.columnSpacing

                                Repeater {
                                    model: Keybinds.columns(Appearance.keybinds.columnCount)

                                    ColumnLayout {
                                        id: column

                                        required property var modelData

                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignTop

                                        spacing: Appearance.keybinds.sectionSpacing

                                        Repeater {
                                            model: column.modelData

                                            KeybindSection {
                                                required property var modelData

                                                title: modelData.title
                                                binds: modelData.binds
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                id: keys

                anchors.fill: parent

                focus: panel.primary

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape)
                        KeybindsState.hide();

                    event.accepted = true;
                }
            }
        }
    }
}
