pragma ComponentBehavior: Bound

import Quickshell

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property var modelData

        BorderExclusions {
            modelData: scope.modelData
        }

        BorderWindow {
            modelData: scope.modelData
        }
    }
}
