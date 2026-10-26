import QtQuick

QtObject {
    readonly property int width: 380
    readonly property int padding: 14
    readonly property real scaleFrom: 0.96
    readonly property int pollMinutes: 30
    readonly property int timeout: 120
    readonly property int headerHeight: 40
    readonly property int headerSpacing: 10
    readonly property int headerIconSize: 20
    readonly property int actionSize: 18
    readonly property int actionSpacing: 12
    readonly property int spinDuration: 900
    readonly property real repoMaxRatio: 0.5
    readonly property int sectionSpacing: 8
    readonly property int sectionRounding: 12
    readonly property int sectionPaddingV: 6
    readonly property int sectionHeaderHeight: 26
    readonly property int sectionHeaderSpacing: 8
    readonly property int sectionIconSize: 16
    readonly property int listSpacing: 2
    readonly property int rowHeight: 32
    readonly property int rowSpacing: 8
    readonly property int rowPaddingH: 10
    readonly property int rowRounding: 8
    readonly property int versionMaxWidth: 96
    readonly property string title: "Updates"
    readonly property string labelRepo: "Repository"
    readonly property string labelAur: "AUR"
    readonly property string versionArrow: "\u2192"
    readonly property string emptyTitle: "Up to date"
    readonly property string emptySubtitle: "No packages waiting"
    readonly property string emptyRepo: "No repository updates"
    readonly property string emptyAur: "No AUR updates"
}
