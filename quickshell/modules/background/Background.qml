pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData

            readonly property string wanted: WallpaperLayout.currentFor(panel.modelData.name)

            function swap(): void {
                if (current.status === Image.Ready) {
                    previous.path = current.path;
                    previous.opacity = 1;
                }

                current.opacity = 0;
                current.path = panel.wanted;
            }

            screen: panel.modelData
            color: Colours.surface
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: Ids.backgroundNamespace

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Component.onCompleted: current.path = panel.wanted
            onWantedChanged: panel.swap()

            WallpaperImage {
                id: previous

                screen: panel.modelData
            }

            WallpaperImage {
                id: current

                screen: panel.modelData
                opacity: 0

                onStatusChanged: {
                    if (current.status === Image.Ready)
                        current.opacity = 1;
                }

                Behavior on opacity {
                    Anim {
                        type: AnimType.standard

                        onFinished: {
                            if (current.opacity === 1)
                                previous.path = "";
                        }
                    }
                }
            }
        }
    }
}
