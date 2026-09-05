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

            function url(path: string): string {
                return path ? `file://${path}` : "";
            }

            function swap(): void {
                if (current.status === Image.Ready) {
                    previous.source = current.source;
                    previous.opacity = 1;
                }

                current.opacity = 0;
                current.source = panel.url(Wallpaper.current);
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

            Component.onCompleted: current.source = panel.url(Wallpaper.current)

            Connections {
                target: Wallpaper

                function onCurrentChanged(): void {
                    panel.swap();
                }
            }

            AnimatedImage {
                id: previous

                anchors.fill: parent

                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(panel.width, panel.height)
            }

            AnimatedImage {
                id: current

                anchors.fill: parent

                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(panel.width, panel.height)
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
                                previous.source = "";
                        }
                    }
                }
            }
        }
    }
}
