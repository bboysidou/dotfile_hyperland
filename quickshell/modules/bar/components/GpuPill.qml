import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.services

UsagePill {
    visible: GpuStats.available
    glyph: Icons.gpu
    percent: GpuStats.busyPercent
    ringColour: Colours.gpu
    section: HardwareSection.gpu
    launchCommand: Terminal.command(Commands.gpuMonitor)
}
