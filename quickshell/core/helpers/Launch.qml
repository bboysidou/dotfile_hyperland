pragma Singleton

import Quickshell
import qs.core.constants

Singleton {
    function app(command: var, workingDirectory: string): void {
        Quickshell.execDetached({
            command: Commands.appScope.concat(command),
            workingDirectory: workingDirectory || ""
        });
    }
}
