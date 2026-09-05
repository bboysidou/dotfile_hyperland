import Quickshell
import Quickshell.Wayland
import qs.core.helpers

PanelWindow {
    id: root

    required property var modelData
    property bool shown: false

    screen: root.modelData
    visible: root.shown && Monitors.focused === root.modelData.name

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
}
