pragma ComponentBehavior: Bound

import Quickshell
import qs.core.config

Scope {
    id: root

    required property var modelData

    Zone {
        anchors.top: true

        exclusiveZone: Appearance.bar.height
    }

    Zone {
        anchors.left: true
    }

    Zone {
        anchors.right: true
    }

    Zone {
        anchors.bottom: true
    }

    component Zone: PanelWindow {
        screen: root.modelData
        color: "transparent"

        mask: Region {}
        exclusiveZone: Appearance.border.thickness

        implicitWidth: 1
        implicitHeight: 1
    }
}
