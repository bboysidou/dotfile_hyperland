import qs.core.config
import qs.core.constants
import qs.services

UsagePill {
    glyph: Icons.cpu
    percent: SysInfo.cpuPercent
    ringColour: Colours.cpu
    launchCommand: Commands.cpuMonitor
}
