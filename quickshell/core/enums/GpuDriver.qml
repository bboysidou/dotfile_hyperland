pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string amdgpu: "amdgpu"
    readonly property string nvidia: "nvidia"
    readonly property string i915: "i915"
    readonly property string xe: "xe"
    readonly property string nouveau: "nouveau"
    readonly property string radeon: "radeon"
    readonly property string none: "none"

    readonly property var values: [root.amdgpu, root.nvidia, root.i915, root.xe, root.nouveau, root.radeon, root.none]
}
