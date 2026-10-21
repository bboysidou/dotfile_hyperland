import QtQuick
import qs.core.enums

QtObject {
    readonly property int width: 1640
    readonly property int maxHeightRatio: 88
    readonly property int padding: 32
    readonly property int rounding: 24
    readonly property int borderWidth: 1
    readonly property int columnCount: 3
    readonly property int columnSpacing: 32
    readonly property int sectionSpacing: 22
    readonly property int rowSpacing: 4
    readonly property int headingWeight: 2

    readonly property int headerSpacing: 12
    readonly property int headerIconSize: 26
    readonly property int titleSize: 22
    readonly property int countSize: 13
    readonly property int headerBottomMargin: 24

    readonly property int sectionTitleSize: 12
    readonly property int sectionTitleSpacing: 8
    readonly property int sectionRuleHeight: 1

    readonly property int rowHeight: 26
    readonly property int rowSpacingH: 14
    readonly property int labelSize: 13
    readonly property int chordSpacing: 4
    readonly property int chordMinWidth: 168

    readonly property int capPaddingH: 7
    readonly property int capPaddingV: 3
    readonly property int capRounding: 6
    readonly property int capBorderWidth: 1
    readonly property int capFontSize: 11
    readonly property int capMinWidth: 22

    readonly property real scaleFrom: 0.97
    readonly property string fadeInType: AnimType.standardLarge
    readonly property string fadeOutType: AnimType.standard

    readonly property string title: "Keybindings"
    readonly property string countTemplate: "%1 binds"
    readonly property string rangeSeparator: "\u2026"
    readonly property string hint: "esc close"
    readonly property string labelOther: "Other"
    readonly property string emptyTitle: "No keybindings"
    readonly property string emptySubtitle: "keymaps.lua could not be read"
}
