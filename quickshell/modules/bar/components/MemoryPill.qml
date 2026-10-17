import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.services

UsagePill {
    glyph: Icons.memory
    percent: SysInfo.memPercent
    ringColour: Colours.memory
    section: HardwareSection.memory
    launchCommand: Commands.memoryMonitor
}
