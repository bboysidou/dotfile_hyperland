pragma ComponentBehavior: Bound

import Quickshell
import qs.core.enums
import qs.services

Scope {
    id: root

    required property var modelData

    Zone {
        anchors.top: true

        exclusiveZone: Prefs.frameThickness(root.modelData.name, BarEdge.top)
    }

    Zone {
        anchors.left: true

        exclusiveZone: Prefs.frameThickness(root.modelData.name, BarEdge.left)
    }

    Zone {
        anchors.right: true

        exclusiveZone: Prefs.frameThickness(root.modelData.name, BarEdge.right)
    }

    Zone {
        anchors.bottom: true

        exclusiveZone: Prefs.frameThickness(root.modelData.name, BarEdge.bottom)
    }

    component Zone: PanelWindow {
        screen: root.modelData
        color: "transparent"

        mask: Region {}

        implicitWidth: 1
        implicitHeight: 1
    }
}
