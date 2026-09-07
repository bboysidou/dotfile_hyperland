import Quickshell
import Quickshell.Wayland
import qs.core.helpers

PanelWindow {
    id: root

    required property var modelData
    property bool shown: false

    readonly property bool covered: Monitors.covered(root.modelData)

    screen: root.modelData
    visible: root.shown && Monitors.focused === root.modelData.name

    color: "transparent"
    exclusionMode: root.covered ? ExclusionMode.Ignore : ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
}
