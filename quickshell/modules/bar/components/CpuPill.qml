import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.services

UsagePill {
    glyph: Icons.cpu
    percent: SysInfo.cpuPercent
    ringColour: Colours.cpu
    section: HardwareSection.cpu
    launchCommand: Commands.cpuMonitor
}
