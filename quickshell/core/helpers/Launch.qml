pragma Singleton

import Quickshell
import qs.core.constants

Singleton {
    function app(command: var, workingDirectory: var): void {
        const directory = workingDirectory ? [Commands.appDirectoryFlag.arg(workingDirectory)] : [];
        Quickshell.execDetached(Commands.appScope.concat(directory, [Commands.endOfOptions], command));
    }
}
