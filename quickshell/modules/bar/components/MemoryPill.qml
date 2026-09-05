import qs.core.config
import qs.core.constants
import qs.services

UsagePill {
    glyph: Icons.memory
    percent: SysInfo.memPercent
    ringColour: Colours.memory
    launchCommand: Commands.memoryMonitor
}
