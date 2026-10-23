import QtQuick

QtObject {
    readonly property int width: 430
    readonly property real scaleFrom: 0.96
    readonly property int headerHeight: 40
    readonly property int headerSpacing: 10
    readonly property int headerIconSize: 20
    readonly property int actionSize: 18
    readonly property int switchTopMargin: 10
    readonly property int bodyTopMargin: 14
    readonly property int blockSpacing: 18
    readonly property int titleSize: 15
    readonly property int titleRuleHeight: 1
    readonly property real ruleOpacity: 0.35

    readonly property int rowHeight: 24
    readonly property int rowSpacing: 8
    readonly property int rowIconWidth: 18
    readonly property int listIndent: 10
    readonly property int procNameWidth: 150
    readonly property int procValueWidth: 92
    readonly property int procMax: 3
    readonly property real procSampleDelay: 0.5

    readonly property int activePollInterval: 2000
    readonly property int idlePollInterval: 10000
    readonly property int procPollInterval: 3000
    readonly property int probeRetryInterval: 30000
    readonly property int coreAverageWindow: 600000
    readonly property int coreAverageMax: 3

    readonly property int cpuTempWarning: 70
    readonly property int cpuTempCritical: 85
    readonly property int gpuTempWarning: 75
    readonly property int gpuTempCritical: 88
    readonly property int khzPerMhz: 1000
    readonly property int mhzPerGhz: 1000
    readonly property int microPerUnit: 1000000
    readonly property int milliPerUnit: 1000
    readonly property int bytesPerMb: 1048576
    readonly property int kbPerMb: 1024
    readonly property int nsPerMs: 1000000

    readonly property int artPadding: 18
    readonly property int pinLength: 9
    readonly property int pinThickness: 2
    readonly property int pinGap: 7
    readonly property int outlineWidth: 2
    readonly property int outlineRounding: 6
    readonly property int dotPitch: 4
    readonly property int dotSize: 1
    readonly property real dotOpacity: 0.85
    readonly property int dieRounding: 4
    readonly property int dieInset: 16
    readonly property int cellRounding: 4
    readonly property int cellSpacing: 9
    readonly property int cellBorderWidth: 1
    readonly property real cellFillOpacity: 0.35
    readonly property int dieBorderWidth: 1
    readonly property int chipDivider: 2
    readonly property int barFrame: 4
    readonly property int gpuBanks: 2
    readonly property int chipHalves: 2
    readonly property real cpuActiveLoad: 0.25
    readonly property int legendGap: 14

    readonly property int cpuColumns: 4
    readonly property int cpuCellSize: 32
    readonly property int cpuCoreDot: 10
    readonly property real cpuIdleFill: 0.08

    readonly property int gpuBars: 5
    readonly property int gpuBarWidth: 36
    readonly property int gpuBarMax: 18
    readonly property int gpuBarMin: 3
    readonly property int gpuBarSpacing: 6
    readonly property int gpuColumnSpacing: 12
    readonly property int gpuChipsPerSide: 3
    readonly property int gpuChipWidth: 30
    readonly property int gpuChipHeight: 34
    readonly property int gpuChipSpacing: 10
    readonly property int gpuChipGap: 22
    readonly property int gpuIconSize: 14

    readonly property int dimmArtHeight: 130
    readonly property int dimmNotchRadius: 7
    readonly property int dimmNotchOffset: 30
    readonly property int dimmPins: 40
    readonly property int dimmPinHeight: 18
    readonly property int dimmPinSpacing: 3
    readonly property real dimmKeyPosition: 0.42
    readonly property int dimmSegments: 36
    readonly property int dimmSegmentHeight: 22
    readonly property int dimmSegmentSpacing: 1
    readonly property int legendSwatch: 10
    readonly property int legendSpacing: 6

    readonly property string title: "Hardware"
    readonly property string labelCpu: "CPU"
    readonly property string labelGpu: "GPU"
    readonly property string labelMemory: "Memory"
    readonly property string labelClock: "Clock Speed"
    readonly property string labelTemp: "Temperature"
    readonly property string labelPower: "Power"
    readonly property string labelUtil: "Utilization"
    readonly property string labelVram: "V-RAM"
    readonly property string labelFan: "Fan Speed"
    readonly property string labelIntegrated: "Integrated"
    readonly property string labelDedicated: "Dedicated"
    readonly property string labelState: "State"
    readonly property string stateSuspended: "Suspended (power saving)"
    readonly property string labelUsage: "Usage"
    readonly property string labelSwap: "Swap"
    readonly property string labelActiveCores: "Active Cores (10 min avg)"
    readonly property string labelTopProcs: "Top Current Processes"
    readonly property string labelTopGpuProcs: "Top GPU Processes"
    readonly property string labelUsed: "Used"
    readonly property string labelCached: "Cached"
    readonly property string labelBuffers: "Buffers"
    readonly property string labelFree: "Free"
    readonly property string labelModules: "Modules"
    readonly property string emptyGpuProcs: "No GPU clients"
    readonly property string emptyDimms: "Install qs-hwinfo to list modules"
    readonly property string titleTemplate: "%1 — %2"
    readonly property string rowTemplate: "%1: "
    readonly property string separator: "|"
    readonly property string fieldSeparator: " | "
    readonly property string bullet: "•"
    readonly property string placeholder: "—"
    readonly property string clockTemplate: "%1 GHz / %2 GHz"
    readonly property string tempTemplate: "%1°C"
    readonly property string powerTemplate: "%1 W"
    readonly property string powerCapTemplate: "%1 W / %2 W"
    readonly property string vramTemplate: "%1 / %2 MB"
    readonly property string fanTemplate: "%1% · %2 RPM"
    readonly property string usageTemplate: "%1 used of %2"
    readonly property string coreTemplate: "Core %1"
    readonly property string coreUsedTemplate: "%1% used"
    readonly property string coresTemplate: "%1% (%2 cores)"
    readonly property string coreTemplateSingle: "%1% (1 core)"
    readonly property string mbTemplate: "%1 MB"
    readonly property string mhzTemplate: "%1 MHz"
    readonly property string legendTemplate: "%1 %2%"
    readonly property int legendPrecision: 1
    readonly property int clockPrecision: 2
    readonly property int powerPrecision: 1
    readonly property int corePadding: 2
}
